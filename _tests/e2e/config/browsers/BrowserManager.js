"use strict";
const fs = require('fs-extra');
const path = require('path');

class BrowserManager {


    createBrowser(browser) {
        if (browser === 'chrome') {
            return this.chromeBrowser('desktop');
        } else if (browser.indexOf('bs_') > -1) {
            return this.browserstackBrowser(browser);
        } else {
            return this.chromeBrowser(browser)
        }
    }

    chromeBrowser(browser) {
        let pathToChromeDownloads = path.resolve('tmp_downloads');
        if (!fs.existsSync(pathToChromeDownloads)) {
            fs.mkdirSync(pathToChromeDownloads);
        }

        let caps;
        if (browser === 'desktop') {
            caps = {
                browserName: 'chrome',
                acceptInsecureCerts: true,

                chromeOptions: {
                    args: ['disable-web-security', 'user-agent=Red Hat Developers Testing'],
                    prefs: {
                        "download": {
                            "default_directory": pathToChromeDownloads,
                            "prompt_for_download": false
                        },
                        profile: {
                            "default_content_setting_values": {"automatic_downloads": 1}
                        }
                    }
                }
            }
        } else {
            caps = {
                browserName: 'chrome',
                acceptInsecureCerts: true,
                chromeOptions: {
                    mobileEmulation: {deviceName: browser},
                    args: ['disable-web-security', 'user-agent=Red Hat Developers Testing'],
                    prefs: {
                        "download": {
                            "default_directory": pathToChromeDownloads,
                            "prompt_for_download": false
                        },
                        profile: {
                            "default_content_setting_values": {"automatic_downloads": 1}
                        },
                    }
                }
            }
        }
        return caps;
    }

    browserstackBrowser(browser) {
        let browserstackBrowser = require("../browsers/remote_browsers.json");
        let browserstackBrowserCaps = browserstackBrowser[browser];
        console.log(`e2e tests running via Browserstack using ${browser} browser`);
        return {
            'project': `RHDP e2e tests: ${browserstackBrowserCaps['browserName']}`,
            'browserstack.local': true,
            'acceptSslCerts': 'true',
            'os': browserstackBrowserCaps['os'],
            'os_version': browserstackBrowserCaps['os_version'],
            'browser_version': browserstackBrowserCaps['browser_version'],
            'platform': browserstackBrowserCaps['platform'],
            'device': browserstackBrowserCaps['device'],
            'browserstack.debug': true,
            'javascriptEnabled': true,
            'acceptInsecureCerts': true
        };
    }
}

module
    .exports = new BrowserManager;
