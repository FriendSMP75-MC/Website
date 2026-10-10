const apiBaseUrl = (
    import.meta.env.VITE_API_BASE_URL
    || 'https://key-backend-for-friendsmp75-website.vercel.app'
).replace(/\/$/, '')

export async function apiFetch(path, options = {}) {
    const response = await fetch(`${apiBaseUrl}${path}`, {
        ...options,
        headers: {
            Accept: 'application/json',
            ...options.headers,
        },
    })

    const contentType = response.headers.get('content-type') || ''
    const payload = contentType.includes('application/json')
        ? await response.json()
        : await response.text()

    if (!response.ok) {
        const message = typeof payload === 'object' && payload?.error
            ? payload.error
            : `Request failed with status ${response.status}`
        throw new Error(message)
    }

    return payload
}

export function getServerStatus() {
    return apiFetch('/server-status')
}

export async function getLatestGroupPhoto() {
    const payload = await apiFetch('/get-gallery-data')
    const photos = Array.isArray(payload)
        ? payload
        : Array.isArray(payload?.data)
            ? payload.data
            : Array.isArray(payload?.images)
                ? payload.images
                : Array.isArray(payload?.items)
                    ? payload.items
                    : Array.isArray(payload?.approved_images)
                        ? payload.approved_images
                : []

    const latestPhoto = [...photos].sort((first, second) => {
        const firstDate = new Date(first.created_at || first.date_taken || first.createdAt || 0).getTime()
        const secondDate = new Date(second.created_at || second.date_taken || second.createdAt || 0).getTime()
        return secondDate - firstDate
    })[0]

    if (!latestPhoto) return null

    return {
        ...latestPhoto,
        url: latestPhoto.image_url
            || latestPhoto.imageUrl
            || latestPhoto.public_url
            || latestPhoto.publicUrl
            || latestPhoto.image_location
            || latestPhoto.storage_path
            || latestPhoto.location
            || latestPhoto.url
            || null,
    }
}
