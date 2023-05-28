import { useAuth } from "../hooks/useAuth";
import PrivateRoute from "../components/PrivateRoute";

import { Box, Button, Text, VStack } from "@chakra-ui/react";

export function HomePage() {
    const auth = useAuth();

    if (auth.isLoading) {
        return <Box />;
    }

    return (
        <PrivateRoute>
            <VStack h={500} justify="center" spacing={8}>
                <Text fontSize="5xl">Welcome to CloudOps-Connect</Text>
                <Text fontSize="4xl">{auth.username} - Home </Text>
                <Button
                    colorScheme="teal"
                    size="lg"
                    onClick={() => auth.signOut()}
                >
                    Log out
                </Button>
            </VStack>
        </PrivateRoute>
    );
}
