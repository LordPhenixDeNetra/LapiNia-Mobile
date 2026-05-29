declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
};

declare module 'https://deno.land/std@0.168.0/http/server.ts' {
  export function serve(
    handler: (request: Request) => Response | Promise<Response>,
  ): void;
}

declare module 'https://esm.sh/@supabase/supabase-js@2' {
  export function createClient(...args: any[]): any;
}
declare module 'https://esm.sh/@supabase/supabase-js@2.45.4' {
  export function createClient(...args: any[]): any;
}

declare module 'https://esm.sh/openai@4' {
  const OpenAI: any;
  export default OpenAI;
}

declare module 'https://esm.sh/@anthropic-ai/sdk@0' {
  const Anthropic: any;
  export default Anthropic;
}
