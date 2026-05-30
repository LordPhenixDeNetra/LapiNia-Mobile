#!/usr/bin/env bash
set -euo pipefail

FUNCTIONS_DIR="${FUNCTIONS_DIR:-/etc/dokploy/compose/supabase-supabase-ie1kda/files/volumes/functions}"
FUNCTIONS_CONTAINER="${FUNCTIONS_CONTAINER:-supabase-supabase-ie1kda-supabase-edge-functions}"
BASE_URL="${BASE_URL:-https://supabase-api.hopitalia-dantec.com}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage:"
  echo "  FUNCTIONS_DIR=... FUNCTIONS_CONTAINER=... BASE_URL=... $0"
  exit 0
fi

mkdir -p "$FUNCTIONS_DIR/sync" "$FUNCTIONS_DIR/calculate-ration" "$FUNCTIONS_DIR/diagnose-symptoms" "$FUNCTIONS_DIR/predict-growth" "$FUNCTIONS_DIR/recommend-race" "$FUNCTIONS_DIR/consanguinity-check"

cat >"$FUNCTIONS_DIR/sync/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type, idempotency-key, Idempotency-Key',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    if (!supabaseUrl || !supabaseAnonKey) {
      return new Response(JSON.stringify({ error: 'Missing Supabase env' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const idempotencyKey =
      req.headers.get('Idempotency-Key') ?? req.headers.get('idempotency-key');
    const authorization = req.headers.get('Authorization') ?? '';

    if (!authorization) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if (!idempotencyKey) {
      return new Response(JSON.stringify({ error: 'Missing Idempotency-Key header' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: authorization,
        },
      },
    });

    const userRes = await supabase.auth.getUser();
    const user = userRes.data.user;
    if (!user) {
      return new Response(JSON.stringify({ error: 'Invalid user session' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { table, operation, payload } = (await req.json()) as any;
    if (!table || !operation || payload === undefined || payload === null) {
      return new Response(
        JSON.stringify({ error: 'Body must include table, operation, payload' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const existing = await supabase
      .from('idempotency_keys')
      .select('key')
      .eq('key', idempotencyKey)
      .maybeSingle();

    if (existing.data?.key) {
      return new Response(
        JSON.stringify({
          ok: true,
          duplicate: true,
          table,
          operation,
          idempotencyKey,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const insertKey = await supabase.from('idempotency_keys').insert({
      key: idempotencyKey,
      user_id: user.id,
    });

    if (insertKey.error) {
      return new Response(JSON.stringify({ error: insertKey.error.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const payloadObj = typeof payload === 'string' ? JSON.parse(payload) : payload;

    if (operation === 'insert') {
      const r = await supabase.from(table).insert(payloadObj).select().maybeSingle();
      if (r.error) throw r.error;
      return new Response(
        JSON.stringify({ ok: true, table, operation, data: r.data }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    if (operation === 'update') {
      const id = payloadObj.id;
      if (!id) {
        return new Response(JSON.stringify({ error: 'Update requires payload.id' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
      const { id: _id, ...updateFields } = payloadObj;
      const r = await supabase.from(table).update(updateFields).eq('id', id).select().maybeSingle();
      if (r.error) throw r.error;
      return new Response(
        JSON.stringify({ ok: true, table, operation, data: r.data }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    if (operation === 'delete') {
      const id = payloadObj.id;
      if (!id) {
        return new Response(JSON.stringify({ error: 'Delete requires payload.id' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
      const r = await supabase.from(table).delete().eq('id', id);
      if (r.error) throw r.error;
      return new Response(
        JSON.stringify({ ok: true, table, operation }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(JSON.stringify({ error: 'Invalid operation' }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
EOF

cat >"$FUNCTIONS_DIR/calculate-ration/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { lapinId, poidsG, stade, temperature = 30 } = (await req.json()) as any;

    const besoinsBase: Record<string, number> = {
      REPOS: 100,
      EN_GESTATION: 120,
      LACTATION: 150,
      ENGRAISSEMENT: 110,
      CROISSANCE: 130,
    };

    const besoinBase = besoinsBase[stade] || 100;

    let facteurTemperature = 1.0;
    if (temperature > 30) {
      facteurTemperature = 0.85;
    } else if (temperature > 25) {
      facteurTemperature = 0.95;
    }

    const besoinFinal = besoinBase * facteurTemperature * (poidsG / 4000);

    const composants = [
      {
        aliment: 'Foin de luzerne',
        quantite_g: Math.round(besoinFinal * 0.5),
        note: 'Source de fibres essentielle',
      },
      {
        aliment: 'Granulés complets',
        quantite_g: Math.round(besoinFinal * 0.3),
        note: 'Complément énergétique et protéique',
      },
      {
        aliment: 'Son de mil',
        quantite_g: Math.round(besoinFinal * 0.15),
        note: 'Énergie supplémentaire',
      },
      {
        aliment: 'Herbe fraîche',
        quantite_g: Math.round(besoinFinal * 0.05),
        note: 'Vitamines et variété',
      },
    ];

    const alertesStock: string[] = [];
    if (stade === 'LACTATION') {
      composants.push({
        aliment: 'Feuilles de moringa',
        quantite_g: Math.round(besoinFinal * 0.1),
        note: 'Riche en protéines pour lactation',
      });
    }

    composants.forEach((c) => {
      if (c.quantite_g <= 0) c.quantite_g = 10;
    });

    const coutTotal = composants.reduce((sum, c) => {
      const prix: Record<string, number> = {
        'Foin de luzerne': 500,
        'Granulés complets': 800,
        'Son de mil': 200,
        'Herbe fraîche': 0,
        'Feuilles de moringa': 0,
      };
      return sum + (c.quantite_g / 1000) * (prix[c.aliment] || 0);
    }, 0);

    const result = {
      lapin_id: lapinId,
      nom_lapin: '',
      stade,
      composants,
      cout_total_fcfa: Math.round(coutTotal),
      alertes_stock: alertesStock,
      besoins_journaliers_g: Math.round(besoinFinal),
    };

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
EOF

cat >"$FUNCTIONS_DIR/diagnose-symptoms/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

interface SymptomCheck {
  nom: string;
  description: string;
  gravite: 'FAIBLE' | 'MODÉRÉ' | 'ÉLEVÉ' | 'CRITIQUE';
}

const SYMPTOMES_COMMUNS: SymptomCheck[] = [
  { nom: "Perte d'appétit", description: 'Le lapin refuse de manger', gravite: 'ÉLEVÉ' },
  { nom: 'Diarrhée', description: 'Selles molles ou liquides', gravite: 'CRITIQUE' },
  { nom: 'Constipation', description: 'Absence de selles', gravite: 'ÉLEVÉ' },
  { nom: 'Maux de ventre', description: 'Le lapin se plaint', gravite: 'MODÉRÉ' },
  { nom: 'Conjonctivite', description: 'Yeux rouges ou pus', gravite: 'MODÉRÉ' },
  { nom: 'Otite', description: 'Tête penchée, oreilles chaudes', gravite: 'ÉLEVÉ' },
  { nom: 'Snuffles', description: 'Éternuements, écoulement nasal', gravite: 'MODÉRÉ' },
  { nom: 'Torticolis', description: 'Tête penchée sur le côté', gravite: 'CRITIQUE' },
  { nom: 'Paralysie', description: 'Impossibilité de se déplacer', gravite: 'CRITIQUE' },
  { nom: 'Alopécie', description: 'Perte de poils localisée', gravite: 'FAIBLE' },
  { nom: 'Gale auriculaire', description: 'Croûtes dans les oreilles', gravite: 'MODÉRÉ' },
  { nom: 'Gale sarcoptique', description: 'Démangeaisons, croûtes sur le corps', gravite: 'ÉLEVÉ' },
  { nom: 'Coccidiose', description: 'Diarrhée sanglante, amaigrissement', gravite: 'CRITIQUE' },
  { nom: 'Ballonnement', description: 'Ventre gonflé, dur', gravite: 'ÉLEVÉ' },
  { nom: 'Verse', description: 'Femelle morte en gestation', gravite: 'CRITIQUE' },
];

const MALADIES_PROBABLES = [
  {
    nom: 'Coccidiose hépatique',
    symptomes: ['Diarrhée', "Perte d'appétit", 'Ballonnement'],
    probabiliteBase: 0.7,
    traitement: 'Toltrazuril 2.5% (0.3 ml/kg oral, 2 jours) ou Sulfadimidine',
    medicaments: ['Toltrazuril', 'Sulfadimidine'],
    delaiAbattage: 21,
    gravite: 'CRITIQUE' as const,
  },
  {
    nom: 'Pasteurellose',
    symptomes: ['Snuffles', 'Conjonctivite', 'Otite'],
    probabiliteBase: 0.6,
    traitement: 'Enrofloxacine 10% (0.5 ml/L eau, 5 jours)',
    medicaments: ['Enrofloxacine', 'Oxytétracycline'],
    delaiAbattage: 14,
    gravite: 'ÉLEVÉ' as const,
  },
  {
    nom: 'Gale auriculaire',
    symptomes: ['Otite', 'Gale auriculaire'],
    probabiliteBase: 0.8,
    traitement: 'Ivermectine 1% (0.2 ml/kg injectable, répéter 7 jours)',
    medicaments: ['Ivermectine'],
    delaiAbattage: 28,
    gravite: 'MODÉRÉ' as const,
  },
  {
    nom: 'Stase gastro-intestinale',
    symptomes: ['Ballonnement', 'Constipation', "Perte d'appétit"],
    probabiliteBase: 0.5,
    traitement: 'Méloxicam + massage ventre + prokinétiques',
    medicaments: ['Méloxicam', 'Probiotiques'],
    delaiAbattage: 7,
    gravite: 'ÉLEVÉ' as const,
  },
  {
    nom: 'Enterite mucoïde',
    symptomes: ['Diarrhée', 'Constipation', 'Maux de ventre'],
    probabiliteBase: 0.4,
    traitement: 'Fenbendazole + réhydratation + probiotiques',
    medicaments: ['Fenbendazole', 'Kaolin-pectine'],
    delaiAbattage: 14,
    gravite: 'MODÉRÉ' as const,
  },
];

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabase = createClient(supabaseUrl, supabaseKey);
    const { lapinId, symptomes, userId } = (await req.json()) as any;

    let lapinInfo: any = {};
    if (lapinId) {
      const { data: lapin } = await supabase
        .from('lapins')
        .select('*, races(*)')
        .eq('id', lapinId)
        .single();
      lapinInfo = lapin;
    }

    const diagnostics: any[] = [];
    let alerteEpidemique = false;
    let nbAnimauxTouches = 0;

    for (const maladie of MALADIES_PROBABLES) {
      const symptomesCorrespondants = symptomes.filter((s: string) =>
        maladie.symptomes.some((ms) => ms.toLowerCase().includes(s.toLowerCase())),
      );

      if (symptomesCorrespondants.length > 0) {
        const scoreCorrespondance = symptomesCorrespondants.length / maladie.symptomes.length;
        const probabilite = Math.min(maladie.probabiliteBase * scoreCorrespondance * 1.2, 0.95);

        diagnostics.push({
          maladie: maladie.nom,
          probabilite: Math.round(probabilite * 100),
          description: `Correspondance: ${symptomesCorrespondants.join(', ')}`,
          traitement: maladie.traitement,
          medicaments: maladie.medicaments,
          delaiAbattage: maladie.delaiAbattage,
        });
      }
    }

    diagnostics.sort((a, b) => b.probabilite - a.probabilite);
    const topDiagnostics = diagnostics.slice(0, 3);

    let urgence = 'FAIBLE';
    if (topDiagnostics.some((d) => d.probabilite > 70)) {
      const maxGravite = ['MODÉRÉ', 'ÉLEVÉ', 'CRITIQUE'].find((g: any) =>
        topDiagnostics.some((d: any) => {
          const mal = MALADIES_PROBABLES.find((m: any) => m.nom === d.maladie);
          return mal?.gravite === g;
        }),
      );
      urgence = maxGravite || 'FAIBLE';
    }

    if (userId) {
      const deuxJoursAgo = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();
      const { count } = await supabase
        .from('sante')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId)
        .eq('type', 'MALADIE')
        .gte('created_at', deuxJoursAgo);

      if (count && count >= 3) {
        alerteEpidemique = true;
        nbAnimauxTouches = count;
      }
    }

    const result = {
      diagnostics: topDiagnostics,
      urgence,
      traitement: topDiagnostics[0]?.traitement || 'Consultation vétér',
      alerte_epidemique: alerteEpidemique,
      animaux_touches: nbAnimauxTouches,
      symptomes_communs: SYMPTOMES_COMMUNS,
      lapin: lapinInfo,
    };

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
EOF

cat >"$FUNCTIONS_DIR/predict-growth/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { raceId, poidsActuelG, ageJours, userId } = (await req.json()) as any;

    const profilRace = {
      poidsAdulteMin: 4.0,
      poidsAdulteMax: 5.0,
      gmQCible: 42,
    };

    const joursRestants = Math.max(0, 180 - ageJours);
    const poidsCible = profilRace.poidsAdulteMax * 1000;
    const gainNecessaire = poidsCible - poidsActuelG;
    const gmQNecessaire = joursRestants === 0 ? 0 : gainNecessaire / joursRestants;

    const courbe = [];
    const poidsActuel = poidsActuelG;

    for (let jour = 0; jour <= 30; jour++) {
      const date = new Date();
      date.setDate(date.getDate() + jour);

      const poidsTheorique = poidsActuel + gmQNecessaire * jour;

      courbe.push({
        date: date.toISOString().split('T')[0],
        poids_g: Math.round(Math.min(poidsTheorique, poidsCible)),
        gmq_jour: Math.round(gmQNecessaire),
      });
    }

    const result = {
      race_id: raceId,
      user_id: userId,
      poids_actuel_g: poidsActuelG,
      poids_cible_g: poidsCible,
      gmq_necessaire_g: Math.round(gmQNecessaire),
      gmq_norme_g: profilRace.gmQCible,
      conforme: gmQNecessaire <= profilRace.gmQCible * 1.1,
      jours_jusqu_cible: joursRestants,
      courbe,
    };

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
EOF

cat >"$FUNCTIONS_DIR/recommend-race/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import OpenAI from 'https://esm.sh/openai@4';
import Anthropic from 'https://esm.sh/@anthropic-ai/sdk@0';

interface AIProvider {
  complete(prompt: string, maxTokens?: number): Promise<string>;
}

class ClaudeProvider implements AIProvider {
  private client: any;

  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }

  async complete(prompt: string, maxTokens: number = 1200): Promise<string> {
    const message = await this.client.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: maxTokens,
      messages: [{ role: 'user', content: prompt }],
    });
    return message.content[0].type === 'text' ? message.content[0].text : '';
  }
}

class OpenAIChatProvider implements AIProvider {
  private client: any;
  private model: string;
  private defaultMaxTokens: number;

  constructor(options: {
    apiKey: string;
    baseURL: string;
    model: string;
    defaultMaxTokens: number;
  }) {
    this.client = new OpenAI({ apiKey: options.apiKey, baseURL: options.baseURL });
    this.model = options.model;
    this.defaultMaxTokens = options.defaultMaxTokens;
  }

  async complete(prompt: string, maxTokens?: number): Promise<string> {
    const chat = await this.client.chat.completions.create({
      model: this.model,
      max_tokens: maxTokens ?? this.defaultMaxTokens,
      messages: [{ role: 'user', content: prompt }],
    });
    return chat.choices[0]?.message?.content ?? '';
  }
}

function safeParseJson(text: string): any | null {
  try {
    return JSON.parse(text);
  } catch {
    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      try {
        return JSON.parse(text.slice(start, end + 1));
      } catch {
        return null;
      }
    }
    return null;
  }
}

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    if (!supabaseUrl || !supabaseAnonKey) {
      return new Response(JSON.stringify({ error: 'Missing Supabase env' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const authorization = req.headers.get('Authorization') ?? '';
    if (!authorization) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: authorization,
        },
      },
    });

    const userRes = await supabase.auth.getUser();
    const user = userRes.data.user;
    if (!user) {
      return new Response(JSON.stringify({ error: 'Invalid user session' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const body = (await req.json()) as any;
    const country = (body?.country ?? '').toString().trim();
    const city = (body?.city ?? '').toString().trim();
    const goal = (body?.goal ?? 'MEAT').toString().trim();
    const resources = Array.isArray(body?.resources)
      ? body.resources.map((e: any) => e?.toString?.() ?? '').filter((e: string) => e.trim().length > 0)
      : [];

    if (!country) {
      return new Response(JSON.stringify({ error: 'Body must include country' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: races, error: racesError } = await supabase
      .from('races')
      .select(
        'id, nom, poids_adulte_min_kg, poids_adulte_max_kg, gmq_cible_g, taille_portee_moyenne, age_1ere_mise_bas_jours, adaptation_chaleur_score, sensibilites_pathologiques',
      )
      .order('nom', { ascending: true });

    if (racesError || !races) {
      return new Response(JSON.stringify({ error: racesError?.message ?? 'Could not load races' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const raceById = new Map<string, any>();
    for (const r of races as any[]) {
      raceById.set(r.id, r);
    }

    const anthropicKey = Deno.env.get('ANTHROPIC_API_KEY');
    const openaiKey = Deno.env.get('OPENAI_API_KEY');
    const mistralKey = Deno.env.get('MISTRAL_API_KEY');
    const deepseekKey = Deno.env.get('DEEPSEEK_API_KEY');
    const kimiKey = Deno.env.get('KIMI_API_KEY') ?? Deno.env.get('MOONSHOT_API_KEY');
    const provider: AIProvider | null = anthropicKey
      ? new ClaudeProvider(anthropicKey)
      : openaiKey
        ? new OpenAIChatProvider({
            apiKey: openaiKey,
            baseURL: 'https://api.openai.com/v1',
            model: 'gpt-4o-mini',
            defaultMaxTokens: 900,
          })
        : mistralKey
        ? new OpenAIChatProvider({
            apiKey: mistralKey,
            baseURL: 'https://api.mistral.ai/v1',
            model: 'mistral-small-latest',
            defaultMaxTokens: 900,
          })
        : deepseekKey
          ? new OpenAIChatProvider({
              apiKey: deepseekKey,
              baseURL: 'https://api.deepseek.com/v1',
              model: 'deepseek-chat',
              defaultMaxTokens: 900,
            })
          : kimiKey
            ? new OpenAIChatProvider({
                apiKey: kimiKey,
                baseURL: 'https://api.moonshot.cn/v1',
                model: 'moonshot-v1-8k',
                defaultMaxTokens: 900,
              })
            : null;

    if (!provider) {
      return new Response(
        JSON.stringify({
          error:
            'IA non configurée (définir au moins une des variables: ANTHROPIC_API_KEY, OPENAI_API_KEY, MISTRAL_API_KEY, DEEPSEEK_API_KEY, KIMI_API_KEY)',
        }),
        {
          status: 501,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const racesList = (races as any[])
      .map((r) => {
        const wmin = r.poids_adulte_min_kg ?? null;
        const wmax = r.poids_adulte_max_kg ?? null;
        const gmq = r.gmq_cible_g ?? null;
        const lit = r.taille_portee_moyenne ?? null;
        const first = r.age_1ere_mise_bas_jours ?? null;
        const heat = r.adaptation_chaleur_score ?? null;
        return `- ${r.nom} (id: ${r.id}) | poids ${wmin ?? '—'}-${wmax ?? '—'} kg | GMQ ${gmq ?? '—'} g/j | portée ${lit ?? '—'} | 1ère mise bas ${first ?? '—'} j | chaleur ${heat ?? '—'}`;
      })
      .join('\n');

    const prompt = `
Tu es un expert en élevage cunicole en Afrique de l'Ouest.

Contexte éleveur:
- Pays: ${country}
- Ville: ${city || '—'}
- Objectif: ${goal} (MEAT, BREEDING, HEAT_RESILIENCE)
- Ressources disponibles: ${resources.length ? resources.join(', ') : '—'}

Tu dois recommander EXACTEMENT 3 races parmi cette liste (ne rien inventer, utiliser exactement les ids):
${racesList}

Retourne UNIQUEMENT du JSON valide, sans texte autour, au format:
{
  "items": [
    {
      "raceId": "<id>",
      "raceName": "<nom>",
      "reasons": ["...","..."],
      "warnings": ["...","..."]
    }
  ]
}
`;

    const raw = await provider.complete(prompt, 1200);
    const parsed = safeParseJson(raw);
    if (!parsed || typeof parsed !== 'object') {
      return new Response(JSON.stringify({ error: 'Could not parse AI response', raw }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const items = Array.isArray(parsed.items) ? parsed.items : [];
    const normalized = items.slice(0, 3).map((it: any) => {
      const raceId = (it?.raceId ?? it?.race_id ?? '').toString();
      const fromDb = raceById.get(raceId);
      const raceName = (it?.raceName ?? it?.race_name ?? fromDb?.nom ?? '').toString();
      const reasons = Array.isArray(it?.reasons) ? it.reasons.map((e: any) => e.toString()) : [];
      const warnings = Array.isArray(it?.warnings) ? it.warnings.map((e: any) => e.toString()) : [];
      return { raceId, raceName, reasons, warnings };
    });

    return new Response(JSON.stringify({ items: normalized }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
EOF

cat >"$FUNCTIONS_DIR/consanguinity-check/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type ConsanguinityLevel = 'OK' | 'WARN' | 'BLOCK' | 'UNKNOWN';

serve(async (req: Request) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY');
    if (!supabaseUrl || !supabaseAnonKey) {
      return new Response(JSON.stringify({ error: 'Missing Supabase env' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const authorization = req.headers.get('Authorization') ?? '';
    if (!authorization) {
      return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const body = (await req.json()) as { mereId?: string; pereId?: string };
    const mereId = body.mereId?.trim();
    const pereId = body.pereId?.trim();
    if (!mereId || !pereId) {
      return new Response(
        JSON.stringify({ error: 'Body must include mereId and pereId' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        },
      );
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authorization } },
    });

    const userRes = await supabase.auth.getUser();
    const user = userRes.data.user;
    if (!user) {
      return new Response(JSON.stringify({ error: 'Invalid user session' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const maxDepth = 3;

    const getAncestors = async (lapinId: string) => {
      const distances = new Map<string, number>();
      let frontier = new Set<string>([lapinId]);

      for (let depth = 1; depth <= maxDepth; depth += 1) {
        const ids = Array.from(frontier);
        if (ids.length === 0) break;

        const { data, error } = await supabase
          .from('genealogie')
          .select('parent_id, lapin_id')
          .in('lapin_id', ids);

        if (error) throw error;
        const next = new Set<string>();
        for (const row of data ?? []) {
          const parentId = (row as any).parent_id as string | null;
          if (!parentId) continue;
          if (!distances.has(parentId)) {
            distances.set(parentId, depth);
          }
          next.add(parentId);
        }
        frontier = next;
      }

      return distances;
    };

    const [a, b] = await Promise.all([getAncestors(mereId), getAncestors(pereId)]);
    const commonAncestors: string[] = [];

    let f = 0;
    for (const [ancestorId, d1] of a.entries()) {
      const d2 = b.get(ancestorId);
      if (!d2) continue;
      commonAncestors.push(ancestorId);
      f += 0.5 * Math.pow(0.5, d1 + d2);
    }

    const level: ConsanguinityLevel =
      commonAncestors.length === 0
        ? 'UNKNOWN'
        : f >= 0.125
          ? 'BLOCK'
          : f >= 0.0625
            ? 'WARN'
            : 'OK';

    return new Response(
      JSON.stringify({
        ok: true,
        f,
        level,
        commonAncestors,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: e?.message ?? String(e) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
EOF

docker restart "$FUNCTIONS_CONTAINER" >/dev/null

sleep 2

curl_status() {
  local method="$1"
  local url="$2"
  local data="${3:-}"

  if [[ "$method" == "GET" ]]; then
    curl -s -o /dev/null -w "%{http_code}" "$url" || true
    return 0
  fi

  curl -s -o /dev/null -w "%{http_code}" -X "$method" \
    -H "Content-Type: application/json" \
    --data "$data" \
    "$url" || true
}

retry_get() {
  local name="$1"
  local url="$2"
  local attempts="${3:-10}"
  local delay_s="${4:-1}"

  local i=1
  while (( i <= attempts )); do
    local status
    status="$(curl_status GET "$url")"
    echo "$name: $status"
    if [[ "$status" != "502" && "$status" != "000" ]]; then
      return 0
    fi
    sleep "$delay_s"
    ((i++))
  done
  return 0
}

retry_get "hello" "$BASE_URL/functions/v1/hello"
retry_get "sync" "$BASE_URL/functions/v1/sync"

echo "calculate-ration: $(curl_status POST "$BASE_URL/functions/v1/calculate-ration" '{"lapinId":"test","poidsG":4000,"stade":"REPOS","temperature":30}')"
echo "diagnose-symptoms: $(curl_status POST "$BASE_URL/functions/v1/diagnose-symptoms" '{"lapinId":null,"symptomes":["Diarrhée"],"userId":null}')"
echo "predict-growth: $(curl_status POST "$BASE_URL/functions/v1/predict-growth" '{"raceId":"test","poidsActuelG":2000,"ageJours":60,"userId":"test"}')"
echo "recommend-race: $(curl_status GET "$BASE_URL/functions/v1/recommend-race")"
echo "consanguinity-check: $(curl_status POST "$BASE_URL/functions/v1/consanguinity-check" '{"mereId":"test","pereId":"test"}')"
