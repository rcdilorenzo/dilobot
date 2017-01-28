// query.js => https://github.com/nijikokun/query-js/
var currentQuery = function() {
    return location.search == '' ? {} : query.parse(location.search);
};

var app = new Vue({
    el: '#wordly-wise',
    data: {
        currentName: currentQuery().name,
        sort: {column: null, ascending: false},
        names: [],
        results: []
    },
    methods: {
        loadNames: function() {
            var self = this;
            axios.get('/api/wordly_wise/names')
                .then(function(response) {
                    self.names = response.data;
                });
        },
        loadResults: function() {
            var self = this;
            axios.get('/api/wordly_wise', {
                params: { name: self.currentName }
            }).then(function(response) {
                console.log(response.data);
                self.results = response.data;
            });
        },
        goToName: function(name) {
            location.search = query.build(
                Object.assign(
                    currentQuery(),
                    { name: name })
            );
            this.currentName = name;
            this.loadResults();
        },
        sortByColumn: function(column) {
            var self = this;
            this.sort = this.sort.column == column ?
                { column: column, ascending: !this.sort.ascending }
                : { column: column, ascending: true };
            this.results = _.reduce(this.results, function(memo, results, name) {
                var sorted = _.sortBy(results, column);
                if (!self.sort.ascending) {
                    sorted.reverse();
                }
                var object = {};
                object[name] = sorted;
                return Object.assign(memo, object);
            }, {});
        }
    }
});

app.loadNames();
app.loadResults();
