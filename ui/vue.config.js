module.exports = {
  devServer: {
    watchOptions: {
      ignored: /node_modules/,
      aggregateTimeout: 300,
      poll: 1000
    },
    disableHostCheck: true,
    public: 'localhost:9999'
  },
  publicPath: '/'
}
