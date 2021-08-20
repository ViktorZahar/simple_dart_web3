module.exports = {
    devtool: 'source-map',
    entry: "./src/simple_ts_web3.ts",
    mode: "development",
    output: {
        filename: "./simple_ts_web3.js",
        library: 'simple_ts_web3',
    },
    resolve: {
        extensions: ['.ts', '.js','.json'],
        aliasFields: ['browser', 'browser.esm']
    },
    module: {
        rules: [
            {
                test: /\.ts?$/,
                use: {
                    loader: 'ts-loader'
                }
            }
        ]
    }
}