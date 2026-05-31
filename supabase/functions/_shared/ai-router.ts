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
