"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { Shield } from "lucide-react";
import Link from "next/link";
import DarkModeToggle from "./ui/DarkModeToggle";

export default function Header() {
  return (
    <div className="px-4 md:px-8 py-4 border-b border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 shadow-sm transition-colors">
      <div className="max-w-7xl mx-auto flex justify-between items-center">
        {/* Logo and Title */}
        <div className="flex items-center gap-4">
          <Link
            href="/"
            className="flex items-center gap-2 hover:opacity-80 transition-opacity"
          >
            <Shield className="h-8 w-8 text-blue-600 dark:text-blue-400 transition-colors" />
            <div>
              <h1 className="font-bold text-xl md:text-2xl text-gray-900 dark:text-white transition-colors">
                MultiSig Timelock
              </h1>
              <p className="text-xs text-gray-500 dark:text-gray-400 hidden md:block transition-colors">
                Secure Multi-Signature Wallet
              </p>
            </div>
          </Link>
        </div>

        {/* Contract Info - Hidden on mobile */}
        <div className="hidden lg:flex flex-col items-center">
          <p className="text-xs text-gray-500 dark:text-gray-400 mb-1 transition-colors">
            Deployed on Sepolia
          </p>
          <a
            href="https://sepolia.etherscan.io/address/0xd1b5cd33bae15f16ceb28c378c77885e4563e024"
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-mono hover:underline transition-colors"
          >
            0xd1b5...e024
          </a>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-3">
          {/* Dark Mode Toggle */}
          <DarkModeToggle />

          {/* GitHub Link - Desktop */}
          <a
            href="https://github.com/Kelechikizito/multisig-wallet-foundry"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden md:flex items-center gap-2 px-4 py-2 rounded-lg bg-gray-900 dark:bg-gray-800 hover:bg-gray-800 dark:hover:bg-gray-700 text-white transition-colors text-sm font-medium border border-gray-700 dark:border-gray-600"
            aria-label="View on GitHub"
          >
            <svg
              className="h-5 w-5"
              fill="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                fillRule="evenodd"
                d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                clipRule="evenodd"
              />
            </svg>
            <span className="hidden lg:inline">GitHub</span>
          </a>

          {/* GitHub Link - Mobile */}
          <a
            href="https://github.com/Kelechikizito/multisig-wallet-foundry"
            target="_blank"
            rel="noopener noreferrer"
            className="md:hidden p-2 rounded-lg bg-gray-900 dark:bg-gray-800 hover:bg-gray-800 dark:hover:bg-gray-700 transition-colors border border-gray-700 dark:border-gray-600"
            aria-label="View on GitHub"
          >
            <svg
              className="h-5 w-5 text-white"
              fill="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                fillRule="evenodd"
                d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                clipRule="evenodd"
              />
            </svg>
          </a>

          {/* Connect Wallet Button */}
          <ConnectButton />
        </div>
      </div>
    </div>
  );
}
