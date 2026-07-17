import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders})
    }

    try {
        const data = await req.json()

       console.log('═══════════════════════════════════════════════════════════')
        console.log('BEACON RECIBIDO')
        console.log('═══════════════════════════════════════════════════════════')
        console.log(`App: ${data.app_name} v${data.app_version}`)
        console.log(`Package: ${data.package_name}`)
        console.log(`Dispositivo: ${data.device_brand} ${data.device_model}`)
        console.log(`Android: ${data.android_version} (SDK ${data.sdk_version})`)
        console.log(`Timestamp: ${data.timestamp}`)
        console.log(`Producción: ${data.is_production}`)
        console.log('═══════════════════════════════════════════════════════════')

        return new Response(
            JSON.stringify({
                success: true,
                message: 'Beacon recibido correctamente',
                received_at : new Date().toISOString()
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json'}
            }
        )
    
    } catch (error) {
        console.error('Error', error)
        return new Response(
            JSON.stringify({error: String(error)}),
            {
                status: 500,
                headers: { ...corsairHeaders, 'Contetn-Type': 'application/json'}
            }
        )
    }
})