import { homePage } from '../../support/pages/Home.page';

const homepageSteps = function () {

    this.Given(/^I am on the Home page$/, function () {
        homePage.open('/');
    });

};

module.exports = homepageSteps;