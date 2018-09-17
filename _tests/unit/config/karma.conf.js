"use strict";
// Karma configuration for running unit-tests in Docker
module.exports = function (config) {
    config.set({
        browsers: ['ChromeHeadless'],
        plugins: [
            'karma-chrome-launcher',
            'karma-jasmine',
            'karma-jasmine-ajax',
            'karma-htmlfile-reporter'
        ],
        //logLevel: config.LOG_DEBUG,
        singleRun: true,
        colors: true,
        frameworks: ['jasmine-ajax', 'jasmine'],
        reporters: ['progress', 'html'],
        htmlReporter: {
            outputFile: '../report/unit-test-report.html',
            pageTitle: 'RHD frontend unit-test results'
        },
        failOnEmptyTestSuite: false,

        files: [
            'jasmine-global.js',
            'https://cdnjs.cloudflare.com/ajax/libs/webcomponentsjs/1.0.14/custom-elements-es5-adapter.js',
            'https://cdnjs.cloudflare.com/ajax/libs/webcomponentsjs/1.0.14/webcomponents-lite.js',
            '../../_docker/drupal/drupal-filesystem/web/themes/custom/rhdp/rhd-frontend/rhd.min.js',
            '../**/*_spec.js'          
        ]
    })
};
