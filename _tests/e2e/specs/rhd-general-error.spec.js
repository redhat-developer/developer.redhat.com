import {GeneralErrorPage} from './support/pages/website/general-error.page';

describe('General Error Page', function () {
    this.retries(2);

    it("@sanity : should contain an <h3> with 'Oh no! We've got a strange feeling about this ...' inside it", function () {
            let generalErrorPage = new GeneralErrorPage();
            generalErrorPage.open('/general-error/');
            expect(generalErrorPage.pageSource()).to.include("<h3>Oh no! We've got a strange feeling about this ...</h3>");
        });
});
