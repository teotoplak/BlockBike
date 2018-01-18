module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*" // Match any network id
        },
        first: {
            host: "localhost",
            port: 8102,
            network_id: "15", // Match any network id,
            from: "0x7921889d9f00817c30f9f470e0bd45c391626dd4"
        },
        second: {
            host: "localhost",
            port: 8103,
            network_id: "15", // Match any network id,
            from: "0x8f3cde768420e88b87c1cbe98ad1d51023dd6652"
        }
    }
};
