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

