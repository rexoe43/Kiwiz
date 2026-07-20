// supabase/functions/chat-llama/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { message } = await req.json() as { message: string }
    
    
    const respuestas = [
      ` ¡Hola! Soy Kiwiz, tu asistente de estudio. Recibí tu mensaje: "${message}"\n\n¿En qué materia necesitas ayuda? ¡Estoy aquí para ti!`,
      `¡Excelente pregunta! "${message}"\n\nVamos a analizarlo juntos paso a paso. ¿Qué parte te genera más dudas?`,
      `Kiwiz reportándose. "${message}" es un tema muy interesante.\n\n¿Quieres que profundice en algún aspecto específico?`,
      `Recibido: "${message}"\n\nDéjame pensar en una buena respuesta para ti. Mientras tanto, ¿tienes alguna otra pregunta?`
    ]
    
    const respuesta = respuestas[Math.floor(Math.random() * respuestas.length)]

    return new Response(
      JSON.stringify({ response: respuesta }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Error desconocido'
    
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})