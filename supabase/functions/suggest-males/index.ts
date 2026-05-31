import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { createAIRouter } from '../_shared/ai-router.ts';

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
      .in('lapin_id', ids)
      .order('lapin_id', { ascending: true })
      .order('parent_id', { ascending: true });

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
    const useAiRaw = body?.useAi ?? body?.use_ai;
    const useAi = typeof useAiRaw === 'boolean'
      ? useAiRaw
      : (useAiRaw == null ? true : String(useAiRaw).toLowerCase() === 'true');

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
      .order('id', { ascending: true })
      .limit(50);

    let { data: males, error: malesError } = await candidateQuery;
    if (malesError) throw malesError;

    if (!males?.length) {
      const r = await supabase
        .from('lapins')
        .select('id, nom, sexe, statut, race_id, races(nom, gmq_cible_g)')
        .eq('sexe', 'M')
        .not('statut', 'in', '("MORT","VENDU")')
        .order('id', { ascending: true })
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
      commonAncestors.sort();

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

    items.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      return (a.maleId as string).localeCompare(b.maleId as string);
    });

    let source: 'ai' | 'deterministic' = 'deterministic';
    if (useAi) {
      try {
        const ai = createAIRouter();
        if (ai.hasProvider()) {
          const top = items.slice(0, 10).map((it) => ({
            maleId: it.maleId,
            nom: it.nom,
            raceNom: it.raceNom,
            score: it.score,
            consanguinite: it.consanguinite,
            croissance: it.croissance,
          }));

          const prompt = [
            `Objectif éleveur: ${objectif}.`,
            `Tu dois proposer un ordre final et des justifications courtes (1 phrase) pour chaque mâle.`,
            `Contraintes:`,
            `- Ne renvoie que du JSON strict (pas de markdown).`,
            `- Conserve uniquement les maleId fournis (pas d'invention).`,
            `- orderedMaleIds doit contenir tous les maleId fournis exactement une fois.`,
            `- Les justifications doivent être courtes, concrètes, et adaptées au contexte cunicole.`,
            ``,
            `Femelle: ${(femelle as any).nom} (id=${(femelle as any).id}).`,
            `Candidats (top 10 calculé): ${JSON.stringify(top)}`,
            ``,
            `Réponds avec: {"orderedMaleIds":["..."],"justifications":{"<maleId>":"..."}}`,
          ].join('\n');

          const raw = await ai.complete(prompt, 'medium');
          const parsed = JSON.parse(raw);
          const ordered = Array.isArray(parsed?.orderedMaleIds) ? parsed.orderedMaleIds.map(String) : null;
          const justifs = parsed?.justifications && typeof parsed.justifications === 'object'
            ? parsed.justifications as Record<string, string>
            : {};

          if (ordered && ordered.length === top.length) {
            const itemsById = new Map<string, any>(items.map((it) => [String(it.maleId), it]));
            const reordered: any[] = [];
            for (const id of ordered) {
              const it = itemsById.get(String(id));
              if (!it) continue;
              const j = justifs[String(id)];
              if (typeof j === 'string' && j.trim().length > 0) {
                it.justification = j.trim().slice(0, 200);
              }
              reordered.push(it);
            }
            if (reordered.length === top.length) {
              source = 'ai';
              items.splice(0, reordered.length, ...reordered);
            }
          }
        }
      } catch (_) {}
    }

    return new Response(
      JSON.stringify({
        objectif,
        source,
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
