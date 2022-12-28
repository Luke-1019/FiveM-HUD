var bar = new ProgressBar.Path('#rpm-progress', {
    easing: 'easeInOut',
    duration: 2500
});

bar.set(0);
bar.animate(0.3);


var fuelBar = new ProgressBar.Circle('#fuel-progress', {
    color: '#79FF58',
    trailColor: 'rgba(255, 255, 255, 0.18)',
    strokeWidth: 10,
    trailWidth: 10,
    easing: 'easeInOut',
    duration: 10,
    strokedasharray: 500,
    text: {
        value: '<svg width="14" height="16" viewBox="0 0 14 16" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M13.3762 2.8449L11.0614 0.138L10.3736 0.75869L11.9839 2.65524C11.011 2.70697 10.2562 3.60352 10.3736 4.62076C10.4575 5.39662 11.0781 6.05179 11.833 6.17248C12.2523 6.22421 12.6549 6.138 12.9736 5.91386V12.6035C12.9736 13.0346 12.6717 13.4483 12.2355 13.4828C11.7491 13.5346 11.3465 13.1552 11.3465 12.638V9.65524C11.3465 8.77593 10.6588 8.06904 9.80329 8.06904H9.40071V2.638C9.40071 1.41386 8.4278 0.396621 7.22006 0.396621H3.09361C1.90264 0.396621 0.912964 1.39662 0.912964 2.638V15.138H9.43425V9.00007H9.83684C10.1891 9.00007 10.4743 9.29317 10.4743 9.65524V12.569C10.4743 13.5173 11.162 14.3449 12.0678 14.3966C13.0575 14.4656 13.913 13.6552 13.913 12.6208V4.29317C13.913 3.75869 13.7117 3.22421 13.3762 2.8449ZM12.1181 5.25869C11.6652 5.25869 11.2962 4.87938 11.2962 4.41386C11.2962 3.94835 11.6652 3.56904 12.1181 3.56904C12.571 3.56904 12.9401 3.94835 12.9401 4.41386C12.9401 4.87938 12.5375 5.25869 12.1181 5.25869ZM6.21361 12.0518C5.92845 12.3277 5.55942 12.4828 5.17361 12.4828C4.7878 12.4828 4.43554 12.3277 4.13361 12.0518C3.58006 11.5001 3.58006 10.569 4.13361 10.0001L4.90522 9.22421C5.03942 9.08628 5.27425 9.08628 5.39167 9.22421L6.16329 10.0001C6.76716 10.5518 6.76716 11.4828 6.21361 12.0518ZM2.42264 5.8449V3.05179C2.42264 2.638 2.74135 2.31041 3.14393 2.31041H7.30393C7.70651 2.31041 8.02522 2.638 8.02522 3.05179V5.8449H2.42264Z" fill="#EFEFEF"/></svg>',
        autoStyleContainer: true,
    },
});

fuelBar.set(0);

$(document).ready(function () {
    updateTime();

    function updateTime() {
        let datetime = new Date();
        let hours = datetime.getHours(),
            minutes = datetime.getMinutes(),
            day = datetime.getDate(),
            month = datetime.getMonth(),
            year = datetime.getFullYear(),
            monat = new Array("Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember");

        document.getElementById("time").innerHTML = `${hours > 9 ? hours : `0` + hours}:${minutes > 9 ? minutes : `0` + minutes}`;
        document.getElementById("year-month-day").innerHTML = `${day}. ${monat[month]} ${year}`;

        setTimeout(updateTime, 10000);
    }

    window.addEventListener("message", function (event) {
        updateTime();

        $('.progressbar').css('width', event.data.count)
        $('.progressbar-2').css('width', event.data.count_2)

        if (event.data !== undefined && event.data.type === "announcement") {
            const content = $(
              `
                <div id="notify" class="top-center">
                    <p>Unity Development</p>
                    <div class="progress-container">
                        <div class="progressbar"></div>
                    </div>
                    <p>` + event.data.message + `</p>
                </div>
              `
            )
            $("#notify-2").prepend(content);
            $('.progressbar').css('width', '0')

            setTimeout(() => {
              content.remove();
            }, 11000)
        }

        if (event.data !== undefined && event.data.type === "notifications") {
            const content = $(
              `
                <div id="notify-2" class="left-bottom-2">
                    <p>Unity Development</p>
                    <p>` + event.data.message + `</p>
                    <div class="progress-container-2">
                        <div class="progressbar-2"></div>
                    </div>
                </div>
              `
            )
            $("#notify-3").prepend(content);
            $('.progressbar-2').css('width', '0')

            setTimeout(() => {
              content.remove();
            }, 6000)
        }

        if (event.data.id < 10) {
            $("#player-id").text("00" + event.data.id);
        } else if (event.data.id >= 10) {
            $("#player-id").text("0" + event.data.id);
        } else if (event.data.id >= 100) {
            $("#player-id").text(event.data.id);
        }
        $("#players").text(event.data.players);
        $("#job-label").text(event.data.job_label);

        if (event.data.status === "weapon") {
            $('.weapon').css('display', 'block');
            $("#ammo").text(event.data.bullets + " bullets");
            $("#weapon-label").text(event.data.weapon);
            document.querySelector(".id-of-img-tag").src = "images/" + event.data.hash + ".png";
        } else if (event.data.status === "weapon-2") {
            $('.weapon').css('display', 'none');
        }

        if (event.data.action == "setMoney") {
            $("#money").text(new Intl.NumberFormat('de-DE').format(event.data.money))
            $("#bank_money").text(new Intl.NumberFormat('de-DE').format(event.data.bank))
        }

        $('.progress-circle-hp').css('stroke-dasharray', event.data.hp);
        $('.progress-circle-vest').css('stroke-dasharray', event.data.vest);
        $('.progress-circle-thirst').css('stroke-dasharray', event.data.thirst);
        $('.progress-circle-hunger').css('stroke-dasharray', event.data.hunger);
        
        if (event.data.light === true) {
            $('#light-icon').css('fill-opacity', '1')
            $('#light-icon').css('fill', "#1BCFC4")
        } else if (event.data.light === false) {
            $('#light-icon').css('fill-opacity', '0.23')
            $('#light-icon').css('fill', "")
        }
        
        if (event.data.engine === true) {
            $('#engine-icon').css('fill-opacity', '1')
            $('#engine-icon').css('fill', "#1BCFC4")
        } else if (event.data.engine === false) {
            $('#engine-icon').css('fill-opacity', '0.23')
            $('#engine-icon').css('fill', "")
        }

        if (event.data.door === true) {
            $('#door-icon').css('fill-opacity', '1')
            $('#door-icon').css('fill', "#1BCFC4")
        } else if (event.data.door === false) {
            $('#door-icon').css('fill-opacity', '0.23')
            $('#door-icon').css('fill', "")
        }

        if (event.data.type === "active") {
            $("#speed").html(event.data.speed);
            $("#rpm-progress").css('stroke-dashoffset', event.data.hud);
            fuelBar.animate(event.data.fuel);
        }
        if (event.data.type === "showui") {
            $('#vehicle-hud').css('display', 'block');
        }
        if (event.data.type === "deactive") {
            $('#vehicle-hud').css('display', 'none');
        }
        if (event.data.action == "toggle") {
            setUISpawn(event.data.show)
        };
    });
});

function setUISpawn(show) {
    if (show) {
        $('#vehicle-hud').css('display', 'block');
    } else {
        $('#vehicle-hud').css('display', 'none');
    }
}

function setAnzahl(anzahl) {
    document.getElementById("content").innerHTML = new Intl.NumberFormat('de-DE').format(anzahl) + " $";
}