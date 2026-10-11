import { useEffect } from 'react'
import { createPortal } from 'react-dom'
import { AlertTriangle, X } from 'lucide-react'
import './ConfirmDialog.css'

export function ConfirmDialog({ open, title, message, confirmLabel = 'Confirm', cancelLabel = 'Cancel', secondaryLabel, destructive = false, onConfirm, onSecondary, onCancel }) {
    useEffect(() => {
        if (!open) return undefined
        const handleKeyDown = (event) => {
            if (event.key === 'Escape') onCancel()
        }
        document.addEventListener('keydown', handleKeyDown)
        const previousOverflow = document.body.style.overflow
        document.body.style.overflow = 'hidden'
        return () => {
            document.removeEventListener('keydown', handleKeyDown)
            document.body.style.overflow = previousOverflow
        }
    }, [open, onCancel])

    if (!open || typeof document === 'undefined') return null

    return createPortal(
        <div className="confirm-overlay" role="presentation" onMouseDown={(event) => event.target === event.currentTarget && onCancel()}>
            <section className="confirm-dialog" role="dialog" aria-modal="true" aria-labelledby="confirm-dialog-title" aria-describedby="confirm-dialog-message">
                <button className="confirm-close" type="button" aria-label="Close confirmation" onClick={onCancel}><X size={18} /></button>
                <div className={`confirm-icon${destructive ? ' confirm-icon-danger' : ''}`}><AlertTriangle size={21} /></div>
                <h2 id="confirm-dialog-title">{title}</h2>
                <p id="confirm-dialog-message">{message}</p>
                <div className="confirm-actions">
                    <button className="confirm-cancel" type="button" onClick={onCancel}>{cancelLabel}</button>
                    {secondaryLabel && <button className="confirm-secondary-danger" type="button" onClick={onSecondary}>{secondaryLabel}</button>}
                    <button className={`confirm-submit${destructive ? ' confirm-submit-danger' : ''}`} type="button" onClick={onConfirm}>{confirmLabel}</button>
                </div>
            </section>
        </div>,
        document.body,
    )
}
