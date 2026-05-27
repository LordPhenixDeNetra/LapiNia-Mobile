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
    const { lapinId, poidsG, stade, temperature = 30 } = await req.json() as any;
    
    const besoinsBase: Record<string, number> = {
      'REPOS': 100,
      'EN_GESTATION': 120,
      'LACTATION': 150,
      'ENGRAISSEMENT': 110,
      'CROISSANCE': 130,
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
    
    composants.forEach(c => {
      if (c.quantite_g <= 0) {
        c.quantite_g = 10;
      }
    });
    
    const coutTotal = composants.reduce((sum, c) => {
      const prix: Record<string, number> = {
        'Foin de luzerne': 500,
        'Granulés complets': 800,
        'Son de mil': 200,
        'Herbe fraîche': 0,
        'Feuilles de moringa': 0,
      };
      return sum + (c.quantite_g / 1000 * (prix[c.aliment] || 0));
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
