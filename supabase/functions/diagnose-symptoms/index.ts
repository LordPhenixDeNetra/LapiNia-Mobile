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
  { nom: 'Perte d\'appétit', description: 'Le lapin refuse de manger', gravite: 'ÉLEVÉ' },
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
    symptomes: ['Diarrhée', 'Perte d\'appétit', 'Ballonnement'],
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
    symptomes: ['Ballonnement', 'Constipation', 'Perte d\'appétit'],
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
    const { lapinId, symptomes, userId } = await req.json() as any;
    
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
        maladie.symptomes.some(ms => ms.toLowerCase().includes(s.toLowerCase()))
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
    if (topDiagnostics.some(d => d.probabilite > 70)) {
      const maxGravite = ['MODÉRÉ', 'ÉLEVÉ', 'CRITIQUE'].find((g: any) =>
        topDiagnostics.some((d: any) => {
          const mal = MALADIES_PROBABLES.find((m: any) => m.nom === d.maladie);
          return mal?.gravite === g;
        })
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
