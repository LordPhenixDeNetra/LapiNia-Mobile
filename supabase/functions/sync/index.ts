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

    const authorization = req.headers.get('Authorization') ?? '';
    const idempotencyKey =
      req.headers.get('Idempotency-Key') ?? req.headers.get('idempotency-key');

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
