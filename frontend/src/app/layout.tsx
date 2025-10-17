import "./globals.css";
import type { Metadata } from "next";
import { type ReactNode } from "react";
import Header from "@/components/Header";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "MultiSignature-timelock Wallet",
  description:
    "A role-based, multi-signature wallet with a timelock functionality",
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="/T-Sender.svg" sizes="any" />
      </head>
      <body className="bg-zinc-50">
        <Providers>
          <Header />
          {props.children}
        </Providers>
      </body>
    </html>
  );
}
