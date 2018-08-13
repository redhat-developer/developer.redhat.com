const baseConfig = require('./wdio.conf.base.js').config;
const BrowserManager = require('./browsers/BrowserManager');
const {execSync} = require('child_process');

browserCaps = BrowserManager.createBrowser(process.env.RHD_JS_DRIVER);

PORT = execSync(`docker ps|grep selhub|sed 's/.*0.0.0.0://g'|sed 's/->.*//g'`);

    const dockerConfig = Object.assign(baseConfig, {
    host: 'localhost',
    port: parseInt(PORT),
    path: '/wd/hub',
    maxInstances: 10,
    capabilities: [browserCaps],
});

exports.config = dockerConfig;
