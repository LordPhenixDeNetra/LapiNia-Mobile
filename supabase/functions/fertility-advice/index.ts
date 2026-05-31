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
