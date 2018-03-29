import {driver} from "../../../config/browsers/DriverHelper";

class BasePage {
    constructor({
                    path = '/',
                    selector,
                } = {}) {
        this.urlBase = process.env.RHD_BASE_URL;
        this.path = path;
        this.selector = selector;
        this.selectors = {};

    }

    open() {
        const openUrl = `${this.urlBase}${this.path}`;
        driver.visit(openUrl);

        if (this.selector) {
            driver.awaitIsVisible(this.selector, 30000);
        }
    }

    addSelectors(selectors) {
        this.selectors = Object.assign(this.selectors, selectors);
    }

    getSelector(selectorName) {
        if (!this.selectors[selectorName]) {
            return console.log(`WARNING: ${selectorName} is not defined as page-object selector!`)
        }
        let selector = '';
        selector += this.selectors[selectorName];
        return selector.trim();
    }

    isLoggedIn(siteUser) {
        let loggedInName = driver.textOf('.logged-in-name');
        return loggedInName === `${siteUser['firstName']} ${siteUser['lastName']}`.toUpperCase()
    }


}

export {
    BasePage
};
