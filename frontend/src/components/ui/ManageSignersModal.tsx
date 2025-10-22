import { useState } from "react";
import { useSigners } from "@/hooks/useSigners";

export default function ManageSignersModal({
  open,
  onClose,
  config,
  multisigAddress,
  publicClient,
}: {
  open: boolean;
  onClose: () => void;
  config: any;
  multisigAddress: `0x${string}` | undefined;
  publicClient: any;
}) {
  const { signers, addSigner, revokeSigner, loading, error } = useSigners(
    config,
    multisigAddress,
    publicClient
  );

  const [newSigner, setNewSigner] = useState("");

  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white dark:bg-gray-900 rounded-xl shadow-lg p-6 w-full max-w-md">
        {/* Header */}
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-semibold">Manage Signers</h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 text-xl leading-none"
          >
            ✕
          </button>
        </div>

        {/* Current signers */}
        <div className="mb-4">
          <p className="text-sm font-medium mb-2">Current Signers</p>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {signers.length > 0 ? (
              signers.map((addr, i) => (
                <div
                  key={i}
                  className="flex justify-between items-center bg-gray-50 dark:bg-gray-800 rounded-md px-3 py-2"
                >
                  <span className="truncate text-sm">{addr}</span>

                  {/* Disable revoke button for the first signer (contract deployer) */}
                  <button
                    onClick={() => revokeSigner(addr as `0x${string}`)}
                    disabled={i === 0 || loading} // 👈 first signer can’t be revoked
                    className={`text-xs px-3 py-1 rounded-md font-medium ${
                      i === 0
                        ? "bg-gray-300 text-gray-600 cursor-not-allowed" // Deployer button style
                        : loading
                        ? "bg-gray-300 text-gray-600 cursor-not-allowed"
                        : "bg-red-600 hover:bg-red-700 text-white"
                    }`}
                  >
                    {i === 0 ? "Owner" : "Revoke"}
                  </button>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-sm">No signers found.</p>
            )}
          </div>
        </div>

        {/* Add new signer */}
        <div className="border-t border-gray-200 dark:border-gray-700 pt-4">
          <p className="text-sm font-medium mb-2">Add New Signer</p>

          {signers.length >= 5 ? (
            // When max signers reached
            <p className="text-red-500 text-sm">
              Maximum of 5 signers reached. Remove one to add a new signer.
            </p>
          ) : (
            // Normal add signer input + button
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="0x..."
                value={newSigner}
                onChange={(e) => setNewSigner(e.target.value)}
                className="flex-1 border border-gray-300 dark:border-gray-700 rounded-lg px-3 py-2 text-sm bg-transparent focus:outline-none"
              />
              <button
                onClick={() => {
                  if (newSigner) {
                    addSigner(newSigner as `0x${string}`);
                    setNewSigner("");
                  }
                }}
                disabled={loading || signers.length >= 5} // 👈 disable button when max reached
                className={`text-sm px-4 py-2 rounded-md font-medium ${
                  loading || signers.length >= 5
                    ? "bg-gray-300 text-gray-600 cursor-not-allowed"
                    : "bg-blue-600 hover:bg-blue-700 text-white"
                }`}
              >
                Add
              </button>
            </div>
          )}
        </div>

        {error && <p className="text-red-500 text-sm mt-3">{error}</p>}
      </div>
    </div>
  );
}
