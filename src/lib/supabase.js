import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = supabaseUrl && supabaseAnonKey
    ? createClient(supabaseUrl, supabaseAnonKey)
    : null

/**
 * Signs the user out immediately, without waiting on the auth server.
 *
 * `supabase.auth.signOut()` awaits a POST /logout round-trip before it clears
 * the local session, so the UI stays signed in until the network responds.
 * Instead we:
 *   1. Grab the access token and revoke the session on the server in the
 *      background (fire-and-forget, errors ignored).
 *   2. Clear the cached session from localStorage synchronously.
 *   3. Call `signOut({ scope: 'local' })` — with storage already empty the
 *      client skips its network call and just emits SIGNED_OUT, so every
 *      auth listener in the app flips to the logged-out state right away.
 */
export function signOutImmediately() {
    if (!supabase) return Promise.resolve()

    const storageKey = supabase.auth.storageKey
    let accessToken = null

    if (storageKey && typeof window !== 'undefined') {
        try {
            const raw = window.localStorage.getItem(storageKey)
            if (raw) accessToken = JSON.parse(raw)?.access_token ?? null

            window.localStorage.removeItem(storageKey)
            window.localStorage.removeItem(`${storageKey}-user`)
            window.localStorage.removeItem(`${storageKey}-code-verifier`)
        } catch {
            // localStorage may be unavailable; the client call below still finishes the sign-out.
        }
    }

    if (accessToken && supabaseUrl) {
        fetch(`${supabaseUrl}/auth/v1/logout?scope=global`, {
            method: 'POST',
            headers: {
                apikey: supabaseAnonKey,
                Authorization: `Bearer ${accessToken}`,
            },
            keepalive: true,
        }).catch(() => {
            // Revocation is best-effort; the user is already signed out locally.
        })
    }

    return supabase.auth.signOut({ scope: 'local' }).catch(() => {})
}
