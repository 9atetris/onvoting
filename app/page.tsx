// app/page.tsx

import { ChakraProvider, Box, Button, Container, Heading, Radio, RadioGroup, Stack, Text } from '@chakra-ui/react';
import { useState } from 'react';

export default function Page() {
    const [value, setValue] = useState('1'); // '1' for YES, '0' for NO

    const submitVote = () => {
        console.log('Submitted vote:', value);
        // TODO: Submit the vote to the smart contract
    };

    return (
        <ChakraProvider>
            <Container centerContent>
                <Box textAlign="center" fontSize="xl">
                    <Heading mb={4}>Voting Booth</Heading>
                    <Text mb={8}>Please cast your vote below:</Text>

                    <RadioGroup onChange={setValue} value={value}>
                        <Stack direction="row" spacing={5} justify="center">
                            <Radio value="1">Yes</Radio>
                            <Radio value="0">No</Radio>
                        </Stack>
                    </RadioGroup>

                    <Button onClick={submitVote} colorScheme="blue" mt={8}>
                        Submit Vote
                    </Button>
                </Box>
            </Container>
        </ChakraProvider>
    );
}
