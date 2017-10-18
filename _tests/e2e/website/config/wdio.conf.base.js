const path = require('path');
const fsExtra = require('fs-extra');

if (typeof process.env.RHD_BASE_URL !== 'undefined') {
    baseUrl = process.env.RHD_BASE_URL
} else {
    baseUrl = 'https://developers.stage.redhat.com'
}

if (process.env.RHD_VERBOSE_OUTPUT) {
    logLevel = 'verbose';
} else {
    logLevel = 'silent';
}

if (typeof process.env.RHD_TEST_PROFILE !== 'undefined') {
    wsReportDirectory = `website/${process.env.RHD_TEST_PROFILE}/results`
} else {
    wsReportDirectory = 'website/results'
}

const pathToChromeDownloads = path.resolve('tmp/chromeDownloads');

let KeyCloakAdmin = require('../../keycloak/features/support/rest/Keycloak.admin');
let keycloakAdmin = new KeyCloakAdmin;
global.siteUser;

exports.config = {

    specs: [
        'website/features/*.feature'
    ],

    exclude: [],

    sync: true,
    //
    // Level of logging verbosity: silent | verbose | command | data | result | error
    logLevel: logLevel,
    //
    // Enables colors for log output.
    coloredLogs: true,
    //
    // If you only want to run your tests until a specific amount of tests have failed use
    // bail (default is 0 - don't bail, run all tests).
    bail: 0,
    //
    // Saves a screenshot to a given path if a command fails.
    // screenshotPath: reportDirectory,
    //
    // Set a base URL in order to shorten url command calls. If your url parameter starts
    // with "/", then the base url gets prepended.
    baseUrl: baseUrl,
    //
    // Default timeout for all waitFor* commands.
    waitforTimeout: 10000,
    //
    // Default timeout in milliseconds for request
    // if Selenium Grid doesn't send response
    connectionRetryTimeout: 90000,
    //
    // Default request retries count
    connectionRetryCount: 3,

    framework: 'cucumber',
    //
    // Test reporter for stdout.
    // The only one supported by default is 'dot'
    // see also: http://webdriver.io/guide/testrunner/reporters.html
    // reporters: ['dot'],//
    // If you are using Cucumber you need to specify the location of your step definitions.
    cucumberOpts: {
        require: ['website/features/step_definitions/', 'keycloak/features/step_definitions/'], // <string[]> (file/dir) require files before executing features
        backtrace: false, // <boolean> show full backtrace for errors
        compiler: [], // <string[]> ("extension:module") require files with the given EXTENSION after requiring MODULE (repeatable)
        dryRun: false, // <boolean> invoke formatters without executing steps
        failFast: false, // <boolean> abort the run on first failure
        format: ['pretty'], // <string[]> (type[:path]) specify the output format, optionally supply PATH to redirect formatter output (repeatable)
        colors: true, // <boolean> disable colors in formatter output
        snippets: true, // <boolean> hide step definition snippets for pending steps
        source: true, // <boolean> hide source uris
        profile: [], // <string[]> (name) specify the profile to use
        strict: false, // <boolean> fail if there are any undefined or pending steps
        // tags: [process.env.CUCUMBER_TAGS],          // <string[]> (expression) only execute the features or scenarios with tags matching the expression
        timeout: 60000, // <number> timeout for step definitions
        ignoreUndefinedDefinitions: false, // <boolean> Enable this config to treat undefined definitions as warnings.
    },

    screenshotPath: `${wsReportDirectory}/errorShots`,

    // Test reporter for stdout.
    // The following are supported: dot (default), spec, and xunit
    // see also: http://webdriver.io/guide/testrunner/reporters.html
    reporters: ['dot', 'junit'],
    reporterOptions: {
        junit: {
            outputDir: wsReportDirectory
        }
    },
    //
    // =====
    // Hooks
    // =====
    // WebdriverIO provides several hooks you can use to interfere with the test process in order to enhance
    // it and to build services around it. You can either apply a single function or an array of
    // methods to it. If one of them returns with a promise, WebdriverIO will wait until that promise got
    // resolved to continue.

    before: function () {
        /**
         * Setup the Chai assertion framework
         */
        const chai = require('chai');
        global.expect = chai.expect;
        global.assert = chai.assert;
        global.should = chai.should();

        fsExtra.mkdirsSync(pathToChromeDownloads);

    },

    beforeScenario: function () {
        let dirSize = [];
        fsExtra.readdirSync(pathToChromeDownloads).forEach(file => {
            dirSize.push(file)
        });

        if (dirSize.length > 0) {
            fsExtra.emptyDir(pathToChromeDownloads)
        }
    },

    afterScenario: function () {
        let dirSize = [];
        fsExtra.readdirSync(pathToChromeDownloads).forEach(file => {
            dirSize.push(file)
        });

        if (dirSize.length > 0) {
            fsExtra.emptyDir(pathToChromeDownloads)
        }

        if (typeof siteUser !== 'undefined') {
            try {
                keycloakAdmin.deleteUser(siteUser['email'])
            } catch (e) {
                console.log('Nothing to delete')
            }
            // if site user is defined the user must be logged off after scenario
            if (baseUrl === 'https://developers.redhat.com') {
                browser.url('https://developers.redhat.com/auth/realms/rhd/protocol/openid-connect/logout?redirect_uri=https%3A%2F%2Fdevelopers.redhat.com%2F');
                browser.pause(1000)
            } else {
                browser.url('https://developers.stage.redhat.com/auth/realms/rhd/protocol/openid-connect/logout?redirect_uri=https%3A%2F%2Fdevelopers.stage.redhat.com%2F');
                browser.pause(1000)
            }
        }
    },

};
