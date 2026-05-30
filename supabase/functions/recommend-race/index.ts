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
