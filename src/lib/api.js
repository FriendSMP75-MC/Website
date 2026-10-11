const apiBaseUrl = (
    import.meta.env.VITE_API_BASE_URL
    || 'https://key-backend-for-friendsmp75-website.vercel.app'
).replace(/\/$/, '')
const backendAccessToken = import.meta.env.VITE_ACCESS_TOKEN

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

function withSession(session, options = {}) {
    return {
        ...options,
        headers: {
            ...options.headers,
            Authorization: `Bearer ${session.access_token}`,
            'X-Access-Token': backendAccessToken || '',
        },
    }
}

export async function checkOwner(session) {
    const configuredOwnerId = String(import.meta.env.VITE_OWNER_UUID_ID || '19e0cc2d-4e3a-412f-85cf-b185c50a5b2e').trim().toLowerCase()
    let backendOwnerId = ''
    try {
        const payload = await apiFetch('/check-owner', withSession(session))
        backendOwnerId = String(payload?.UUID_ID || payload?.uuid_id || payload?.owner_id || '').trim().toLowerCase()
    } catch {
        // Fall back to the configured owner id when the backend check is unreachable.
    }
    const ownerId = backendOwnerId || configuredOwnerId
    if (!ownerId) return false
    const identities = session.user.identities || []
    const discordIdentity = identities.find((identity) => identity.provider === 'discord')
    const candidates = [
        session.user.id,
        session.user.email,
        session.user.user_metadata?.email,
        session.user.user_metadata?.provider_id,
        session.user.user_metadata?.sub,
        session.user.user_metadata?.user_name,
        session.user.user_metadata?.preferred_username,
        session.user.user_metadata?.full_name,
        session.user.user_metadata?.name,
        discordIdentity?.identity_data?.provider_id,
        discordIdentity?.identity_data?.sub,
        discordIdentity?.identity_data?.email,
        ...identities.flatMap((identity) => [
            identity.identity_data?.provider_id,
            identity.identity_data?.sub,
            identity.identity_data?.email,
        ]),
    ].filter(Boolean).map((value) => String(value).trim().toLowerCase())

    const matched = candidates.includes(ownerId)
    return matched
}

export async function getStaffUuids(session) {
    const payload = await apiFetch('/get-staff-uuids', withSession(session))
    return Array.isArray(payload) ? payload : payload?.data || payload?.staff || []
}

export async function checkStaffAccess(session) {
    const staffRecords = await getStaffUuids(session)
    const identityIds = [
        session.user.id,
        session.user.user_metadata?.provider_id,
        session.user.user_metadata?.sub,
        ...((session.user.identities || []).flatMap((identity) => [
            identity.identity_data?.provider_id,
            identity.identity_data?.sub,
        ])),
    ].filter(Boolean).map(String)

    return staffRecords.some((record) => {
        const recordIds = [
            record.staff_uid,
            record.uuid,
            record.user_id,
            record.discord_id,
            record.provider_id,
        ].filter(Boolean).map(String)
        return recordIds.some((recordId) => identityIds.includes(recordId))
    })
}

export async function addStaffUuid(session, uuid, nickname) {
    return apiFetch('/add-uuid', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ uuid, nickname }),
    }))
}

export function deleteStaffUuid(session, uuid) {
    return apiFetch(`/delete-uuid/${encodeURIComponent(uuid)}`, withSession(session, { method: 'DELETE' }))
}

export function createAnnouncement(session, { title, body, author, authorUuid }) {
    return apiFetch('/new-announcements', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            title,
            body,
            author,
            author_uuid: authorUuid,
        }),
    }))
}

export function uploadGalleryImage(session, { file, author, authorUuid, takenDate }) {
    const formData = new FormData()
    formData.append('image', file)
    formData.append('author', author)
    formData.append('author_uuid', authorUuid)
    formData.append('taken_date', takenDate)

    return apiFetch('/upload-image', withSession(session, {
        method: 'POST',
        body: formData,
    }))
}

export function submitMemoryRequest(session, { file, title, dateTaken }) {
    const user = session.user
    const displayName = user.user_metadata?.full_name
        || user.user_metadata?.user_name
        || user.user_metadata?.preferred_username
        || user.email
        || 'Member'
    const formData = new FormData()
    formData.append('image', file)
    formData.append('uuid', user.id)
    formData.append('display_name', displayName)
    formData.append('displayname', displayName)
    formData.append('date_taken', dateTaken)
    if (title.trim()) formData.append('title', title.trim())

    return apiFetch('/memory-request-add', withSession(session, {
        method: 'POST',
        body: formData,
    }))
}

export async function getMemberMemoryRequests(session) {
    const payload = await apiFetch(`/member-memory-requests?uuid=${encodeURIComponent(session.user.id)}`, withSession(session))
    return Array.isArray(payload) ? payload : payload?.data || payload?.requests || []
}

export async function getStaffMemoryRequests(session) {
    const payload = await apiFetch('/staff-memory-requests', withSession(session))
    return Array.isArray(payload) ? payload : payload?.data || payload?.requests || []
}

export function updateMemoryRequestStatus(session, requestId, status, staffNote = '') {
    const payload = { request_id: requestId, status }
    if (staffNote.trim()) payload.staff_note = staffNote.trim()

    return apiFetch('/staff-memory-request-action', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
    }))
}

export function deleteMemoryRequest(session, requestId) {
    return apiFetch(`/staff-memory-requests/${encodeURIComponent(requestId)}`, withSession(session, { method: 'DELETE' }))
}

export function sendDiscordAnnouncement(session, payload) {
    return apiFetch('/send-dm', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
    }))
}

export function getServerAccessStatus() {
    return apiFetch('/server-status')
}

export function serverPowerAction(session, action) {
    return apiFetch(`/server-${action}`, withSession(session, { method: 'POST' }))
}

export function getStaffApplicationStatus() {
    return apiFetch('/staff-app-status')
}

export function checkStaffApplication(session) {
    return apiFetch('/staff-application-check', withSession(session))
}

export function getAnnouncements() {
    return apiFetch('/get-announcements')
}

export function getPunishmentHistory(session, username) {
    return apiFetch(`/punishment-history?username=${encodeURIComponent(username)}`, withSession(session))
}

export function updateStaffApplicationStatus(session, isOpen) {
    return apiFetch('/update-staff-app-status', withSession(session, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_open: isOpen }),
    }))
}

export function getSubmittedApplications(session) {
    return apiFetch('/get-submitted-applications', withSession(session))
}

export function submitStaffVote(session, applicationUid, voteType) {
    return apiFetch('/submit-staff-vote', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ application_uid: applicationUid, vote_type: voteType }),
    }))
}

export function finalizeStaffApplication(session, applicationUid, status, explanation) {
    return apiFetch('/finalize-staff-application', withSession(session, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ application_uid: applicationUid, status, review_explanation: explanation }),
    }))
}

function extractPhotos(payload) {
    return Array.isArray(payload)
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
}

function normalizePhoto(photo) {
    return {
        ...photo,
        url: photo.image_url
            || photo.imageUrl
            || photo.public_url
            || photo.publicUrl
            || photo.image_location
            || photo.storage_path
            || photo.location
            || photo.url
            || null,
    }
}

export async function getGalleryPhotos() {
    const photos = extractPhotos(await apiFetch('/get-gallery-data'))
    return photos
        .map(normalizePhoto)
        .filter((photo) => photo.url)
        .sort((first, second) => {
            const firstDate = new Date(first.created_at || first.date_taken || first.createdAt || 0).getTime()
            const secondDate = new Date(second.created_at || second.date_taken || second.createdAt || 0).getTime()
            return secondDate - firstDate
        })
}

export async function getMemoryPhotos() {
    const photos = extractPhotos(await apiFetch('/public-approved-images'))
    return photos
        .map(normalizePhoto)
        .filter((photo) => photo.url)
        .sort((first, second) => {
            const firstDate = new Date(first.created_at || first.date_taken || first.createdAt || 0).getTime()
            const secondDate = new Date(second.created_at || second.date_taken || second.createdAt || 0).getTime()
            return secondDate - firstDate
        })
}

export async function getLatestGroupPhoto() {
    return (await getGalleryPhotos())[0] || null
}
