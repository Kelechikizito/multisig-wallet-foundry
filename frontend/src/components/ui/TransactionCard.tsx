import {
  Shield,
  Clock,
  Users,
  Send,
  CheckCircle,
  XCircle,
  AlertCircle,
} from "lucide-react";
import React from "react";

type Transaction = {
  id: number;
  to: string;
  amount: number;
  confirmations: number;
  executed: boolean;
  timelock?: number;
};

type TransactionCardProps = {
  tx: Transaction;
  onConfirm: (id: number) => void;
  onRevoke: (id: number) => void;
  onExecute: (id: number) => void;
  isLoading?: boolean;
};

export default function TransactionCard({
  tx,
  onConfirm,
  onRevoke,
  onExecute,
}: TransactionCardProps): JSX.Element {
  const getTimelockBadge = (amount: number) => {
    if (amount < 1)
      return { text: "No Delay", color: "bg-green-100 text-green-800" };
    if (amount < 10)
      return { text: "1 Day", color: "bg-yellow-100 text-yellow-800" };
    if (amount < 100)
      return { text: "2 Days", color: "bg-orange-100 text-orange-800" };
    return { text: "7 Days", color: "bg-red-100 text-red-800" };
  };

  const badge = getTimelockBadge(tx.amount);
  const progress = (tx.confirmations / 3) * 100;

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-6 shadow-sm hover:shadow-md transition-shadow dark:bg-gray-800 text-gray-900 dark:text-white">
      {/* Header */}
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-2">
            <h3 className="font-semibold text-gray-900 dark:text-white">
              Transaction #{tx.id}
            </h3>
            <span
              className={`px-2 py-1 rounded-full text-xs font-medium ${badge.color}`}
            >
              <Clock className="h-3 w-3 inline mr-1" />
              {badge.text}
            </span>
          </div>
          <p className="text-sm text-gray-600 mb-1">
            To: {tx.to.slice(0, 6)}...{tx.to.slice(-4)}
          </p>
          <p className="text-lg font-bold text-gray-900 dark:text-white">
            {tx.amount} ETH
          </p>
        </div>
        <div
          className={`px-3 py-1 rounded-full text-xs font-medium ${
            tx.executed
              ? "bg-green-100 text-green-800"
              : tx.confirmations >= 3
              ? "bg-blue-100 text-blue-800"
              : "bg-gray-100 text-gray-800"
          }`}
        >
          {tx.executed
            ? "Executed"
            : tx.confirmations >= 3
            ? "Ready"
            : "Pending"}
        </div>
      </div>

      {/* Progress */}
      <div className="mb-4">
        <div className="flex justify-between text-sm mb-2">
          <span className="text-gray-600">Confirmations</span>
          <span className="font-medium text-gray-900">
            {tx.confirmations} / 3
          </span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div
            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${Math.min(progress, 100)}%` }}
          />
        </div>
      </div>

      {/* Timelock Info */}
      {tx.timelock && (
        <div className="flex items-center gap-2 mb-4 p-3 bg-orange-50 rounded-lg">
          <AlertCircle className="h-4 w-4 text-orange-600" />
          <p className="text-sm text-orange-800">
            Unlocks: {new Date(tx.timelock).toLocaleString()}
          </p>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex flex-col gap-2">
        {/* Show execute when ready (≥3 confirmations) */}
        {!tx.executed && tx.confirmations >= 3 && (
          <button 
          onClick={() => onExecute(tx.id)}
          className="w-full flex items-center justify-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors">
            <Send className="h-4 w-4" />
            Execute Transaction
          </button>
        )}

        {/* Always show confirm/revoke if not executed */}
        {!tx.executed && (
          <div className="flex gap-2">
            <button
              onClick={() => onConfirm(tx.id)}
              className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors"
            >
              <CheckCircle className="h-4 w-4" />
              Confirm
            </button>
            <button
              onClick={() => onRevoke(tx.id)}
              className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg font-medium transition-colors"
            >
              <XCircle className="h-4 w-4" />
              Revoke
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
