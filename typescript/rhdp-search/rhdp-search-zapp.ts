// import {RHDPSearchURL} from './rhdp-search-url';
// import {RHDPSearchQuery} from './rhdp-search-query';
// import {RHDPSearchBox} from './rhdp-search-box';
// import {RHDPSearchResultCount} from './rhdp-search-result-count';
// import {RHDPSearchFilters} from './rhdp-search-filters';
// import {RHDPSearchOneBox} from './rhdp-search-onebox';
// import {RHDPSearchResults} from './rhdp-search-results';
// import {RHDPSearchSortPage} from './rhdp-search-sort-page';

class RHDPSearchApp extends HTMLElement {
    constructor() {
        super();
        //this.toggleModal = this.toggleModal.bind(this);
        //this.updateFacets = this.updateFacets.bind(this);
    }

    _name = 'Search';
    _url;

    get name() {
        return this._name;
    }

    set name(val) {
        if (this._name === val) return;
        this._name = val;
        this.setAttribute('name', this.name);
    }

    get url() {
        return this._url;
    }

    set url(val) {
        if (this._url === val) return;
        this._url = val;
        this.query.url = this.url;
        this.setAttribute('url', this.url);
    }

    template = `<div class="row">
    <span class="search-outage-msg"></span>
    <div class="large-24 medium-24 small-24 columns searchpage-middle">
        <div class="row">
            <div class="large-24 medium-24 small-24 columns">
                <h2>${this.name}</h2>
            </div>
        </div>
        <div class="row">
            <div class="large-6 medium-8 small-24 columns"></div>
            <div class="large-18 medium-16 small-24 columns"></div>
        </div>
    </div></div>`;

    urlEle = new RHDPSearchURL();
    query = new RHDPSearchQuery();
    box = new RHDPSearchBox();
    count = new RHDPSearchResultCount();
    filters = new RHDPSearchFilters();
    active = new RHDPSearchFilters();
    modal = new RHDPSearchFilters();
    onebox = new RHDPSearchOneBox();
    results = new RHDPSearchResults();
    sort = new RHDPSearchSortPage();

    filterObj = {
        term:'', 
        facets: [
            { name: 'CONTENT TYPE', key: 'sys_type', items: [
                {key: 'apidocs', name: 'APIs and Docs', value: ['rht_website', 'rht_apidocs'], type: ['apidocs']},
                {key: 'archetype', name: 'Archetype', value: ['jbossdeveloper_archetype'], type: ['jbossdeveloper_archetype']},
                {key: 'article', name: 'Article', value: ['article', 'solution'], type: ['rhd_knowledgebase_article', 'rht_knowledgebase_solution']},
                {key: 'blogpost', name: "Blog Posts", value: ['blogpost'], type: ['jbossorg_blog']},
                {key: 'book', name: "Book", value: ["book"], type: ["jbossdeveloper_book"]},
                {key: 'bom', name: "BOM", value: ["jbossdeveloper_bom"], type: ['jbossdeveloper_bom']},
                {key: 'cheatsheet', name: "Cheat Sheet", value: ['cheatsheet'], type: ['jbossdeveloper_cheatsheet']},
                {key: 'demo', name: 'Demo', value: ['demo'], type: ['jbossdeveloper_demo']},
                {key: 'event', name: 'Event', value: ['jbossdeveloper_event'], type: ['jbossdeveloper_event']},
                {key: 'forum', name: 'Forum', value: ['jbossorg_sbs_forum'], type: ['jbossorg_sbs_forum']},
                {key: 'get-started', name: "Get Started", value: ["jbossdeveloper_example"], type: ['jbossdeveloper_example'] },
                {key: 'quickstart', name: "Quickstart", value: ['quickstart'], type: ['jbossdeveloper_quickstart']},
                {key: 'stackoverflow', name: 'Stack Overflow', value: ['stackoverflow_thread'], type: ['stackoverflow_question']},
                {key: 'video', name: "Video", value: ["video"], type:['jbossdeveloper_vimeo', 'jbossdeveloper_youtube'] },
                {key: 'webpage', name: "Web Page", value: ['webpage'], type: ['rhd_website']}
                ] 
            },
            {
                name:'PRODUCT', 
                key: 'product', 
                items: [
                {key: 'dotnet', name: '.NET Runtime for Red Hat Enterprise Linux', value: ['dotnet']},
                {key: 'amq', name: 'JBoss A-MQ', value: ['amq']},
                {key: 'bpmsuite', name: 'JBoss BPM Suite', value: ['bpmsuite']},
                {key: 'brms', name: 'Red Hat Decision Manager', value: ['brms']},
                {key: 'datagrid', name: 'JBoss Data Grid', value: ['datagrid']},
                {key: 'datavirt', name: 'JBoss Data Virtualization', value: ['datavirt']},
                {key: 'devstudio', name: 'JBoss Developer Studio', value: ['devstudio']},
                {key: 'eap', name: 'JBoss Enterprise Application Platform', value: ['eap']},
                {key: 'fuse', name: 'JBoss Fuse', value: ['fuse']},
                {key: 'webserver', name: 'JBoss Web Server', value: ['webserver']},
                {key: 'openjdk', name: 'OpenJDK', value: ['openjdk']},
                {key: 'rhamt', name: 'Red Hat Application Migration Toolkit', value: ['rhamt']},
                {key: 'cdk', name: 'Red Hat Container Development Kit', value: ['cdk']},
                {key: 'developertoolset', name: 'Red Hat Developer Toolset', value: ['developertoolset']},
                {key: 'devsuite', name: 'Red Hat Development Suite', value: ['devsuite']},
                {key: 'rhel', name: 'Red Hat Enterprise Linux', value: ['rhel']},
                {key: 'mobileplatform', name: 'Red Hat Mobile Application Platform', value: ['mobileplatform']},
                {key: 'openshift', name: 'Red Hat OpenShift Container Platform', value: ['openshift']},
                {key: 'softwarecollections', name: 'Red Hat Software Collections', value: ['softwarecollections']}
                ]
            },
            { name: 'TOPIC', key: 'tag', items: [
                {key: 'dotnet', name: '.NET', value: ['dotnet','.net','visual studio','c#']},
                {key: 'containers', name: 'Containers', value: ['atomic','cdk','containers']},
                {key: 'devops', name: 'DevOps', value: ['DevOps','CI','CD','Continuous Delivery']},
                {key: 'enterprise-java', name: 'Enterprise Java', value: ['ActiveMQ','AMQP','apache camel','Arquillian','Camel','CDI','CEP','CXF','datagrid','devstudio','Drools','Eclipse','fabric8','Forge','fuse','Hawkular','Hawtio','Hibernate','Hibernate ORM','Infinispan','iPaas','java ee','JavaEE','JBDS','JBoss','JBoss BPM Suite','Red Hat Decision Manager','JBoss Data Grid','jboss eap','JBoss EAP','']},
                {key: 'iot', name: 'Internet of Things', value: ['IoT','Internet of Things']},
                {key: 'microservices', name: 'Microservices', value: ['Microservices',' WildFly Swarm']},
                {key: 'mobile', name: 'Mobile', value: ['Mobile','Red Hat Mobile','RHMAP','Cordova','FeedHenry']},
                {key: 'web-and-api-development', name: 'Web and API Development', value: ['Web','API','HTML5','REST','Camel','Node.js','RESTEasy','JAX-RS','Tomcat','nginx','Rails','Drupal','PHP','Bottle','Flask','Laravel','Dancer','Zope','TurboGears','Sinatra','httpd','Passenger']},
                ] 
            }
        ]
    };

    connectedCallback() {
        this.innerHTML = this.template;

        this.active.setAttribute('type', 'active');
        this.active.title = 'Active Filters:';
        this.modal.setAttribute('type', 'modal');
        this.modal.filters = this.filterObj;
        this.active.filters = this.filterObj;
        this.filters.filters = this.filterObj;
        this.query.filters = this.filterObj;
        
        //document.querySelector('.wrapper').appendChild(this.modal);
        document.body.appendChild(this.modal);
        this.querySelector('.row .large-24 .row .large-24').appendChild(this.query);
        this.querySelector('.row .large-24 .row .large-24').appendChild(this.box);
        this.querySelector('.large-6').appendChild(this.filters);
        this.querySelector('.large-18').appendChild(this.active);
        this.querySelector('.large-18').appendChild(this.count);
        this.querySelector('.large-18').appendChild(this.sort);
        this.querySelector('.large-18').appendChild(this.onebox);
        this.querySelector('.large-18').appendChild(this.results);
        document.body.appendChild(this.urlEle);
    }

    static get observedAttributes() { 
        return ['url', 'name']; 
    }

    attributeChangedCallback(name, oldVal, newVal) {
        this[name] = newVal;
    }

    toggleModal(e) {
        this.modal.toggle = e.detail.toggle;
    }

    updateSort(e) {
        this.query.sort = e.detail.sort;
        this.query.from = 0;
        this.results.last = 0;
        this.count.term = this.box.term;
    }
}

customElements.define('rhdp-search-app', RHDPSearchApp);