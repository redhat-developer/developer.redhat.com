"use strict";
/* global RHDPSearchBox */
// Test rhdp-search-box component

describe('Search Box', function() {
    var wc;
    beforeEach(function() {
        wc = new RHDPSearchBox();
    });

    it('should be true', function() {
        expect(wc.innerText).toEqual('');
    });
});