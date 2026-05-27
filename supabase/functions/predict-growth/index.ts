import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { raceId, poidsActuelG, ageJours, userId } = await req.json();
    
    const profilRace = {
      poidsAdulteMin: 4.0,
      poidsAdulteMax: 5.0,
      gmQCible: 42,
    };
    
    const joursRestants = Math.max(0, 180 - ageJours);
    const poidsCible = profilRace.poidsAdulteMax * 1000;
    const gainNecessaire = poidsCible - poidsActuelG;
    const gmQNecessaire = gainNecessaire / joursRestants;
    
    const courbe = [];
    const poidsActuel = poidsActuelG;
    
    for (let jour = 0; jour <= 30; jour++) {
      const date = new Date();
      date.setDate(date.getDate() + jour);
      
      const poidsTheorique = poidsActuel + (gmQNecessaire * jour);
      
      courbe.push({
        date: date.toISOString().split('T')[0],
        poids_g: Math.round(Math.min(poidsTheorique, poidsCible)),
        gmq_jour: Math.round(gmQNecessaire),
      });
    }
    
    const result = {
      poids_actuel_g: poidsActuelG,
      poids_cible_g: poidsCible,
      gmq_necessaire_g: Math.round(gmQNecessaire),
      gmq_norme_g: profilRace.gmQCible,
      conforme: gmQNecessaire <= profilRace.gmQCible * 1.1,
      jours_jusqu_cible: joursRestants,
      courbe: courbe,
    };
    
    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
