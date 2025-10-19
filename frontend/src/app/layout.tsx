import "./globals.css";
import type { Metadata } from "next";
import { type ReactNode } from "react";
import Header from "@/components/Header";
import { Providers } from "./providers";
// Remove the import for ThemeProvider here, since it's already in Providers

export const metadata: Metadata = {
  title: "MultiSignature-timelock Wallet",
  description:
    "A role-based, multi-signature wallet with a timelock functionality",
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" href="k" sizes="any" />
      </head>
      <body className="">
        <Providers>
          <Header />
          {props.children}
        </Providers>
      </body>
    </html>
  );
}