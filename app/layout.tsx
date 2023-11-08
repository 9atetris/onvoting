// app/layout.tsx

import { ReactNode } from 'react';
import { ChakraProvider } from '@chakra-ui/react';

export default function Layout({ children }: { children: ReactNode }) {
    return <ChakraProvider>{children}</ChakraProvider>;
}
