app.sso = function () {

    function updateUser() {
        var usr = digitalData.user[0].profile[0].profileInfo;

        if (keycloak.authenticated) {
            keycloak.updateToken().success(function () {
                saveTokens();

                var logged_in_user = keycloak.tokenParsed['name'];

                // show username instead of full name if full name is empty or blank (only space character)
                if (logged_in_user.replace(/\s/g, "").length < 1) {
                    logged_in_user = "My Account";
                }

                $('a.logged-in-name')
                    .text(logged_in_user)
                    .attr('href', app.ssoConfig.account_url)
                    .show();
                $('li.login, li.register, li.login-divider, section.register-banner, .hidden-after-login').hide();
                $('section.contributors-banner, .shown-after-login, li.logged-in').show();
                $('li.login a, a.keycloak-url').attr("href", keycloak.createAccountUrl())
                // once the promise comes back, listen for a click on logout
                $('a.logout').on('click',function(e) {
                    e.preventDefault();
                    keycloak.logout({"redirectUri":app.ssoConfig.logout_url});
                });

                usr.loggedIn = true;

                usr.keyCloakID = keycloak.tokenParsed['id'];
                usr.daysSinceRegistration = daysDiff(Date.now(), keycloak.tokenParsed['createdTimestamp']);
                
                if (typeof Object.keys == "function") {
                    usr.socialAccountsLinked = Object.keys(keycloak.tokenParsed['user-social-links'])
                } else {
                    for (social in keycloak.tokenParsed['user-social-links']) {
                        usr.socialAccountsLinked.push(social);
                    }
                }

            }).error(clearTokens);
        } else {
            $('li.login, section.register-banner, .hidden-after-login').show();
            $('li.logged-in, section.contributors-banner, .shown-after-login, li.logged-in').hide();
            $('li.logged-in').hide();
            $('li.login a').on('click',function(e){
                e.preventDefault();
                keycloak.login();
            });
            $('li.register a, a.keycloak-url').on('click',function(e){
                e.preventDefault();
                keycloak.login({ action : 'register', redirectUri : app.ssoConfig.confirmation });
            });
        }

        updateAnalytics(usr);
    }

    function daysDiff(dt1, dt2) {
        return Math.floor(Math.abs(dt1-dt2)/(1000*60*60*24))
    }

    function updateAnalytics(usr) {
        var ddUserAuthEvent = {
            eventInfo: {
                eventName: 'user data',
                eventAction: 'available',
                user: [{
                    profile: [{
                        profileInfo: usr
                    }]
                }],
                timeStamp: new Date(),
                processed: {
                    adobeAnalytics: false
                }
            }
        };

        //Push it onto the event array of the digitalData object
        window.digitalData = window.digitalData || {};
        digitalData.event = digitalData.event || [];
        digitalData.event.push(ddUserAuthEvent);
        //Update digitalData.page.listing objects
        digitalData.user = digitalData.user || [{ profile: [{ profileInfo: {} }] }];
        digitalData.user[0].profile[0].profileInfo = usr;
        //Create and dispatch an event trigger using the predefined function
        sendCustomEvent('ajaxAuthEvent');
    }

    function saveTokens() {
        if (keycloak.authenticated) {
            var tokens = {token: keycloak.token, refreshToken: keycloak.refreshToken};
            if (storageAvailable('localStorage')) {
                window.localStorage.token = JSON.stringify(tokens);
            } else {
                document.cookie = 'token=' + btoa(JSON.stringify(tokens));
            }
        } else {
            if (storageAvailable('localStorage')) {
                delete window.localStorage.token;
            } else {
                document.cookie = "token=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
            }
        }
    }

    function loadTokens() {
        if (storageAvailable('localStorage')) {
            if (window.localStorage.token) {
                return JSON.parse(window.localStorage.token);
            }
        } else {
            var name = 'token=';
            var ca = document.cookie.split(';');
            for (var i = 0; i < ca.length; i++) {
                var c = ca[i];

                while (c.charAt(0) == ' ') {
                    c = c.substring(1);
                }

                if (c.indexOf(name) == 0) {
                    return JSON.parse(atob(c.substring(name.length, c.length)));
                }
            }
        }
    }

    function clearTokens() {
        keycloak.clearToken();
        if (storageAvailable('localStorage')) {
            window.localStorage.token = "";
        } else {
            document.cookie = 'token=' + btoa("");
        }
    }

    function checkIfProtectedPage() {
        if ($('.protected').length) {
            if (!keycloak.authenticated) {
                keycloak.login();
            }
        }
    }

    var keycloak = Keycloak({
        url: app.ssoConfig.auth_url,
        realm: 'rhd',
        clientId: 'web'
    });
    app.keycloak = keycloak;
    var tokens = loadTokens();
    var init = {onLoad: 'check-sso', checkLoginIframeInterval: 10};
    if (tokens) {
        init.token = tokens.token;
        init.refreshToken = tokens.refreshToken;
    }

    keycloak.onAuthLogout = updateUser;

    keycloak.init(init).success(function (authenticated) {
        updateUser(authenticated);
        saveTokens();
        checkIfProtectedPage();

        if ($('.downloadthankyou').length && app.termsAndConditions) {
            app.termsAndConditions.download();
        }
        
    }).error(function () {
        updateUser();
    });


};

function storageAvailable(type) {
    try {
        var storage = window[type],
        x = '__storage_test__';
        storage.setItem(x, x);
        storage.removeItem(x);
        return true;
    }
    catch(e) {
        return false;
    }
}
 

// Call app.sso() straight away, the call is slow, and enough of the DOM is loaded by this point anyway
app.sso();

