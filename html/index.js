$(function () {
    function display(bool) {
        if (bool) {
            $("#window").show();
        } else {
            $("#window").hide();
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
    })

    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('http://master_minerJob/exit', JSON.stringify({}));
            return
        }
    };
	
    $("#close").click(function () {
        $.post('http://master_minerJob/exit', JSON.stringify({}));
        return
    })
	
    $(".btn").click(function () {
		var ItemName = $(this).data('item');
        $.post('http://master_minerJob/sell', JSON.stringify({"item":ItemName}));
        return
    })
})