"use strict";
// Test rhdp-downloads-all component

describe('Downloads All Product Items', function () {
    var wc;

    beforeEach(function () {
        wc = document.createElement('rhdp-downloads-all-item');
        wc.name = 'Test Product';
        wc.productId = 'testproduct';
        wc.dataFallbackUrl = 'http://www.testproduct.com';
        wc.downloadUrl = 'http://www.downloadtestproduct.com';
        wc.description = 'This is a description for a solid test product';
        wc.learnMore = 'http://www.testproduct.com/learnmore';
        wc.version = '1.0.0';

        document.body.insertBefore(wc, document.body.firstChild);

    });

    afterEach(function () {
        document.body.removeChild(document.body.firstChild);
    });

    describe('properties', function () {

        it('should update the name property', function () {
            expect(wc.name).toEqual('Test Product');


        });
        it('should update the productId property', function () {
            expect(wc.productId).toEqual('testproduct');


        });
        it('should update the dataFallbackUrl property', function () {
            expect(wc.dataFallbackUrl).toEqual('http://www.testproduct.com');


        });
        it('should update the downloadUrl property', function () {
            expect(wc.downloadUrl).toEqual('http://www.downloadtestproduct.com');


        });
        it('should update the description property', function () {
            expect(wc.description).toEqual('This is a description for a solid test product');


        });
        it('should update the learnMore property', function () {
            expect(wc.learnMore).toEqual('http://www.testproduct.com/learnmore');


        });
        it('should update the version property', function () {
            expect(wc.version).toEqual('1.0.0');


        });

    });
    describe('with valid data', function () {


        it('should update the heading', function () {
            expect(wc.querySelector('.row .large-24.column').innerText.trim()).toEqual('Test Product');
        });
        it('should update the description with the appropriate text', function () {
            expect(wc.querySelector('.large-10.columns .paragraph p').innerText.trim()).toEqual('This is a description for a solid test product');
        });
        it('should update the href the appropriate learnmore link', function () {
            expect(wc.querySelector('.large-10.columns .paragraph p').innerText.trim()).toEqual('This is a description for a solid test product');
        });
        it('should update the datafallback with the appropriate url', function () {
            expect(wc.querySelector('.large-5.columns a').getAttribute('data-fallback-url')).toEqual('http://www.testproduct.com');
        });
        it('should update the downloadURL with the appropriate text', function () {
            expect(wc.querySelector('.large-5.columns a').href).toEqual('http://www.downloadtestproduct.com/');
        });
        it('should update the productID with the appropriate text', function () {
            expect(wc.querySelector('.large-5.columns a').getAttribute('data-download-id')).toEqual('testproduct');
        });
        it('should update the version with the appropriate text', function () {
            expect(wc.querySelector('.large-9.center.columns p').innerText.trim()).toEqual('Version: 1.0.0');
        });

    });

});