Event.observe(window, "load", function() {
    download_pending_event = $$('.download-pending').first();
    if (download_pending_event) {
        new ReleaseDownloadObserver(download_pending_event.href, download_pending_event.getAttribute("data-release-id"));
    };
});

/*
  When a download_pending link is detected, we're checking
  every 5 seconds the release status (by retrieving the json).
  When release is downloaded, we're reloading the page.
*/
ReleaseDownloadObserver = Class.create({
    initialize: function(base_url, identifier) {
        this.base_url = base_url;
        this.identifier = identifier;
        this.periodical_executer();
    },
    reload_when_downloaded: function(transport) {
        var release = transport.responseText.evalJSON().release;
        if (release.status != 'download_pending') {
            reload_page();
        }
    },
    reload_page: function() {
        window.location = this.base_url;
    },
    check_if_release_is_downloaded: function() {
        new Ajax.Updater({ success: 'release_' + this.identifier }, this.base_url + '/' + this.identifier + "/description", {
            method: 'get', onSuccess: this.reload_when_downloaded.bind(this), onFailure: this.reload_page.bind(this)
        });
    },
    periodical_executer: function() {
        new PeriodicalExecuter(this.check_if_release_is_downloaded.bind(this), 10);
    }
});