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

mkdir -p "$FUNCTIONS_DIR/_shared" "$FUNCTIONS_DIR/sync" "$FUNCTIONS_DIR/calculate-ration" "$FUNCTIONS_DIR/diagnose-symptoms" "$FUNCTIONS_DIR/predict-growth" "$FUNCTIONS_DIR/recommend-race" "$FUNCTIONS_DIR/consanguinity-check" "$FUNCTIONS_DIR/fertility-advice" "$FUNCTIONS_DIR/suggest-males"

cat >"$FUNCTIONS_DIR/_shared/ai-router.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
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
  
  async complete(prompt: string, maxTokens: number = 1000): Promise<string> {
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

export const SYSTEM_PROMPT_CUNICULTURE = `Tu es un expert en élevage cunicole (lapins) en Afrique de l'Ouest. 
Tu connais parfaitement:
- Les races de lapins (NZW, Californien, Rex, Géant des Flandres, etc.)
- La reproduction et la gestation (31 jours)
- L'alimentation (foin, granulés, luzerne, fanes, moringa)
- Les maladies courantes (coccidiose, pasteurellose, Gale)
- La croissance et le GMQ (gain moyen quotidien)
- Les bonnes pratiques d'élevage en climat chaud

Réponds de manière concise, pratique et adaptée au contexte local (Sénégal, Mali, Côte d'Ivoire).
Utilise des unités métriques (grammes, kg, °C).
`;

export class AIRouter {
  private claude: ClaudeProvider | null = null;
  private openai: OpenAIChatProvider | null = null;
  private mistral: OpenAIChatProvider | null = null;
  private deepseek: OpenAIChatProvider | null = null;
  private kimi: OpenAIChatProvider | null = null;
  
  constructor() {
    const anthropicKey = Deno.env.get('ANTHROPIC_API_KEY');
    const openaiKey = Deno.env.get('OPENAI_API_KEY');
    const mistralKey = Deno.env.get('MISTRAL_API_KEY');
    const deepseekKey = Deno.env.get('DEEPSEEK_API_KEY');
    const kimiKey = Deno.env.get('KIMI_API_KEY') ?? Deno.env.get('MOONSHOT_API_KEY');
    
    if (anthropicKey) {
      this.claude = new ClaudeProvider(anthropicKey);
    }
    if (openaiKey) {
      this.openai = new OpenAIChatProvider({
        apiKey: openaiKey,
        baseURL: 'https://api.openai.com/v1',
        model: 'gpt-4o-mini',
        defaultMaxTokens: 800,
      });
    }
    if (mistralKey) {
      this.mistral = new OpenAIChatProvider({
        apiKey: mistralKey,
        baseURL: 'https://api.mistral.ai/v1',
        model: 'mistral-small-latest',
        defaultMaxTokens: 800,
      });
    }
    if (deepseekKey) {
      this.deepseek = new OpenAIChatProvider({
        apiKey: deepseekKey,
        baseURL: 'https://api.deepseek.com/v1',
        model: 'deepseek-chat',
        defaultMaxTokens: 800,
      });
    }
    if (kimiKey) {
      this.kimi = new OpenAIChatProvider({
        apiKey: kimiKey,
        baseURL: 'https://api.moonshot.cn/v1',
        model: 'moonshot-v1-8k',
        defaultMaxTokens: 800,
      });
    }
  }

  hasProvider(): boolean {
    return !!(this.claude || this.openai || this.mistral || this.deepseek || this.kimi);
  }
  
  async complete(prompt: string, complexity: 'low' | 'medium' | 'high' = 'medium'): Promise<string> {
    const fullPrompt = `${SYSTEM_PROMPT_CUNICULTURE}\n\nQuestion: ${prompt}`;
    
    if (complexity === 'high' && this.claude) {
      return await this.claude.complete(fullPrompt, 1500);
    }
    
    if (this.mistral) {
      return await this.mistral.complete(fullPrompt, 800);
    }

    if (this.openai) {
      return await this.openai.complete(fullPrompt, 800);
    }

    if (this.deepseek) {
      return await this.deepseek.complete(fullPrompt, 800);
    }

    if (this.kimi) {
      return await this.kimi.complete(fullPrompt, 800);
    }
    
    if (this.claude) {
      return await this.claude.complete(fullPrompt, 1000);
    }
    
    throw new Error('No AI provider configured');
  }
  
  async diagnose(symptomes: string[], lapinInfo: any): Promise<any> {
    if (!this.claude) {
      throw new Error('Claude required for diagnosis');
    }
    
    const prompt = `${SYSTEM_PROMPT_CUNICULTURE}

Analyse ces symptômes pour un lapin:
- Race: ${lapinInfo.race}
- Âge: ${lapinInfo.age} jours
- Poids: ${lapinInfo.poids}g
- Statut: ${lapinInfo.statut}
- Symptômes rapportés: ${symptomes.join(', ')}

Donne-moi:
1. Les 3 diagnostics les plus probables avec %
2. Le niveau d'urgence (FAIBLE, MODÉRÉ, ÉLEVÉ, CRITIQUE)
3. Un traitement suggéré
4. Les médicaments courants (nom, dosage ml/kg, voie)

Réponds en JSON: {diagnostics: [{maladie, probabilite, traitement, medicament, dosage}], urgence, traitement}`;

    const result = await this.claude.complete(prompt, 1500);
    
    try {
      return JSON.parse(result);
    } catch {
      return { error: 'Could not parse AI response', raw: result };
    }
  }
  
  async calculateRation(lapinInfo: any, temperature: number): Promise<any> {
    if (!this.mistral && !this.openai && !this.deepseek && !this.kimi && !this.claude) {
      throw new Error('No AI provider configured');
    }
    
    const prompt = `${SYSTEM_PROMPT_CUNICULTURE}

Calcule une ration quotidienne pour:
- Race: ${lapinInfo.race}
- Stade: ${lapinInfo.stade} (REPOS, GESTATION, LACTATION, etc.)
- Poids: ${lapinInfo.poids}g
- Température ambiante: ${temperature}°C

Donne-moi les quantités en grammes pour chaque aliment disponible:
- Foin de luzerne
- Granulés complets
- Son de mil
- Fanes de carottes
- Feuilles de moringa
- Herbe de Guinée

Réponds en JSON: {composants: [{aliment, quantite_g, note}], alertes_stock: [], cout_total_fcfa}`;

    const provider = this.mistral || this.openai || this.deepseek || this.kimi || this.claude;
    const result = await provider!.complete(prompt, 1000);
    
    try {
      return JSON.parse(result);
    } catch {
      return { error: 'Could not parse AI response', raw: result };
    }
  }
}

export const createAIRouter = () => new AIRouter();

if (import.meta.main) {
  const aiRouter = new AIRouter();

  serve(async (req: Request) => {
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, Idempotency-Key',
    };

    if (req.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      const { action, prompt, complexity, symptomes, lapinInfo, temperature } = await req.json() as any;
      
      let result: any;
      
      switch (action) {
        case 'complete':
          result = { response: await aiRouter.complete(prompt, complexity) };
          break;
        case 'diagnose':
          result = await aiRouter.diagnose(symptomes, lapinInfo);
          break;
        case 'calculate-ration':
          result = await aiRouter.calculateRation(lapinInfo, temperature);
          break;
        default:
          throw new Error(`Unknown action: ${action}`);
      }
      
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
}
EOF

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

cat >"$FUNCTIONS_DIR/fertility-advice/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { createAIRouter } from '../_shared/ai-router.ts';

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

function fallbackRecommendations(): string[] {
  return [
    "Vérifier l'état corporel et ajuster l'alimentation (foin à volonté + granulés de qualité, eau propre permanente).",
    "Réduire le stress (chaleur, bruit, manipulations) et améliorer la ventilation: viser < 30°C si possible.",
    "Contrôler la santé reproductive (gale, coccidiose, pasteurellose) et isoler/traiter tout sujet suspect.",
    'Éviter la sur-utilisation: respecter des temps de repos entre saillies et surveiller les performances sur 2–3 portées.',
    "Vérifier l'âge et renouveler les reproducteurs si baisse persistante (mâles souvent moins performants après 18–24 mois selon conduite).",
  ];
}

function normalizeRecommendations(value: any): string[] {
  if (!value) return [];

  if (Array.isArray(value)) {
    return value.map((e) => e?.toString?.() ?? '').map((s) => s.trim()).filter((s) => s.length > 0);
  }

  if (typeof value === 'object') {
    const arr = value.recommendations ?? value.recommandations ?? value.items ?? value.advice ?? null;
    if (Array.isArray(arr)) {
      return arr.map((e) => e?.toString?.() ?? '').map((s) => s.trim()).filter((s) => s.length > 0);
    }
  }

  return [];
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

    const body = (await req.json()) as any;
    const lapinId = (body?.lapinId ?? body?.lapin_id ?? '').toString().trim();
    const scoreNow = body?.scoreNow ?? body?.score_now ?? body?.score ?? null;
    const scoreBefore = body?.scoreBefore ?? body?.score_before ?? null;
    const context = (body?.context ?? body?.contexte ?? '').toString().trim();

    let lapin: any = null;
    if (lapinId) {
      const { data } = await supabase
        .from('lapins')
        .select('id, nom, sexe, date_naissance, statut, score_fertilite, race_id, races(nom, gmq_cible_g)')
        .eq('id', lapinId)
        .maybeSingle();
      lapin = data ?? null;
    }

    const ai = createAIRouter();
    if (!ai.hasProvider()) {
      return new Response(
        JSON.stringify({ recommendations: fallbackRecommendations(), source: 'fallback' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const prompt = `
Cas: baisse de fertilité chez un lapin d'élevage.

Contexte (optionnel): ${context || '—'}

Données lapin:
- id: ${lapin?.id ?? lapinId || '—'}
- nom: ${lapin?.nom ?? '—'}
- sexe: ${lapin?.sexe ?? '—'}
- statut: ${lapin?.statut ?? '—'}
- race: ${lapin?.races?.nom ?? '—'}
- score actuel: ${scoreNow ?? lapin?.score_fertilite ?? '—'}/100
- score il y a 3 mois: ${scoreBefore ?? '—'}/100

Tu dois proposer 3 à 6 recommandations concrètes, actionnables et adaptées à l'Afrique de l'Ouest (climat chaud), en français.
Retourne UNIQUEMENT du JSON valide, sans texte autour, au format:
{
  "recommendations": ["...", "..."]
}
`;

    const raw = await ai.complete(prompt, 'medium');
    const parsed = safeParseJson(raw);
    const recs = normalizeRecommendations(parsed);

    if (!recs.length) {
      return new Response(
        JSON.stringify({ recommendations: fallbackRecommendations(), source: 'fallback' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(JSON.stringify({ recommendations: recs.slice(0, 6), source: 'ai' }), {
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

cat >"$FUNCTIONS_DIR/suggest-males/index.ts" <<'EOF'
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type Objective = 'anti-consanguinite' | 'croissance' | 'equilibre';
type ConsanguinityLevel = 'OK' | 'WARN' | 'BLOCK' | 'UNKNOWN';

const OBJECTIVES: Objective[] = ['anti-consanguinite', 'croissance', 'equilibre'];

function objectiveWeights(objectif: Objective): { wCons: number; wGrowth: number } {
  switch (objectif) {
    case 'anti-consanguinite':
      return { wCons: 0.7, wGrowth: 0.3 };
    case 'croissance':
      return { wCons: 0.3, wGrowth: 0.7 };
    case 'equilibre':
    default:
      return { wCons: 0.5, wGrowth: 0.5 };
  }
}

async function getAncestors(
  supabase: any,
  lapinId: string,
  maxDepth: number,
): Promise<Map<string, number>> {
  const distances = new Map<string, number>();
  let frontier = new Set<string>([lapinId]);

  for (let depth = 1; depth <= maxDepth; depth += 1) {
    const ids = Array.from(frontier);
    if (!ids.length) break;

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
}

function consanguinityLevel(f: number, commonCount: number, hasDataA: boolean, hasDataB: boolean): ConsanguinityLevel {
  if (commonCount === 0) {
    if (!hasDataA || !hasDataB) return 'UNKNOWN';
    return 'OK';
  }
  if (f >= 0.125) return 'BLOCK';
  if (f >= 0.0625) return 'WARN';
  return 'OK';
}

function consanguinityScore(level: ConsanguinityLevel, f: number): number {
  if (level === 'UNKNOWN') return 0.6;
  const normalized = 1 - Math.min(1, f / 0.125);
  return Math.max(0, Math.min(1, normalized));
}

function growthScore(gmqCibleG: number | null, maxGmq: number | null): number {
  if (!gmqCibleG || !maxGmq || maxGmq <= 0) return 0.5;
  return Math.max(0, Math.min(1, gmqCibleG / maxGmq));
}

function buildJustification(params: {
  level: ConsanguinityLevel;
  f: number;
  gmqCibleG: number | null;
  gScore: number;
}): string {
  const parts: string[] = [];

  if (params.level === 'OK') parts.push('Consanguinité faible');
  if (params.level === 'WARN') parts.push('Consanguinité modérée');
  if (params.level === 'BLOCK') parts.push('Consanguinité élevée');
  if (params.level === 'UNKNOWN') parts.push('Consanguinité inconnue');

  if (params.gmqCibleG) {
    if (params.gScore >= 0.75) parts.push('Bon potentiel de croissance');
    else if (params.gScore >= 0.55) parts.push('Croissance correcte');
    else parts.push('Croissance à surveiller');
  } else {
    parts.push('Croissance non renseignée');
  }

  if (params.level !== 'UNKNOWN') {
    parts.push(`F=${params.f.toFixed(3)}`);
  }

  return parts.join(' • ');
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

    const body = (await req.json()) as any;
    const femelleId = (body?.femelleId ?? body?.femelle_id ?? '').toString().trim();
    const objectifRaw = (body?.objectif ?? body?.objective ?? 'equilibre').toString().trim();

    if (!femelleId) {
      return new Response(JSON.stringify({ error: 'Body must include femelleId' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const objectif = (OBJECTIVES.includes(objectifRaw as Objective)
      ? (objectifRaw as Objective)
      : 'equilibre') as Objective;

    const { data: femelle } = await supabase
      .from('lapins')
      .select('id, nom, sexe, race_id')
      .eq('id', femelleId)
      .maybeSingle();

    if (!femelle) {
      return new Response(JSON.stringify({ error: 'Femelle not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    if ((femelle as any).sexe !== 'F') {
      return new Response(JSON.stringify({ error: 'Lapin femelleId must be a female (sexe=F)' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const candidateQuery = supabase
      .from('lapins')
      .select('id, nom, sexe, statut, race_id, races(nom, gmq_cible_g)')
      .eq('sexe', 'M')
      .in('statut', ['REPOS', 'DISPONIBLE_SAILLIE'])
      .limit(50);

    let { data: males, error: malesError } = await candidateQuery;
    if (malesError) throw malesError;

    if (!males?.length) {
      const r = await supabase
        .from('lapins')
        .select('id, nom, sexe, statut, race_id, races(nom, gmq_cible_g)')
        .eq('sexe', 'M')
        .not('statut', 'in', '("MORT","VENDU")')
        .limit(50);
      males = r.data ?? [];
      if (r.error) throw r.error;
    }

    const maxDepth = 3;
    const ancestorsFemelle = await getAncestors(supabase, femelleId, maxDepth);

    let maxGmq: number | null = null;
    for (const m of males ?? []) {
      const g = (m as any)?.races?.gmq_cible_g ?? null;
      if (typeof g === 'number') {
        maxGmq = maxGmq === null ? g : Math.max(maxGmq, g);
      }
    }

    const weights = objectiveWeights(objectif);

    const items: any[] = [];
    for (const m of males ?? []) {
      const maleId = (m as any).id as string;
      const ancestorsMale = await getAncestors(supabase, maleId, maxDepth);

      const commonAncestors: string[] = [];
      let f = 0;
      for (const [ancestorId, d1] of ancestorsFemelle.entries()) {
        const d2 = ancestorsMale.get(ancestorId);
        if (!d2) continue;
        commonAncestors.push(ancestorId);
        f += 0.5 * Math.pow(0.5, d1 + d2);
      }

      const level = consanguinityLevel(
        f,
        commonAncestors.length,
        ancestorsFemelle.size > 0,
        ancestorsMale.size > 0,
      );

      const consScore = consanguinityScore(level, f);
      const gmqCibleG = ((m as any)?.races?.gmq_cible_g ?? null) as number | null;
      const gScore = growthScore(gmqCibleG, maxGmq);
      const total = weights.wCons * consScore + weights.wGrowth * gScore;
      const score = Math.round(total * 100);

      items.push({
        maleId,
        nom: (m as any).nom,
        raceId: (m as any).race_id ?? null,
        raceNom: (m as any)?.races?.nom ?? null,
        score,
        justification: buildJustification({ level, f, gmqCibleG, gScore }),
        consanguinite: {
          f,
          level,
          commonAncestors,
        },
        croissance: {
          gmqCibleG,
        },
      });
    }

    items.sort((a, b) => b.score - a.score);

    return new Response(
      JSON.stringify({
        objectif,
        femelle: { id: (femelle as any).id, nom: (femelle as any).nom },
        items: items.slice(0, 10),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
echo "fertility-advice: $(curl_status POST "$BASE_URL/functions/v1/fertility-advice" '{"lapinId":"test","scoreNow":60,"scoreBefore":85,"context":"chaleur"}')"
echo "suggest-males: $(curl_status POST "$BASE_URL/functions/v1/suggest-males" '{"femelleId":"test","objectif":"equilibre"}')"
