.pragma library

function makeRequest(http, method, request, processAnswer) {
    console.log("try to make request.", "http.readyState:", http.readyState);
    if (http.readyState === 0) {
        console.log("send request")
        http.onreadystatechange = function() {
            console.log("http.readyState:", http.readyState);
            if (http.readyState === 4/*DONE*/) {
                if (http.status === 200/*OK*/) {
                    console.log("http.response:", http.responseText);
                    var json = JSON.parse(http.response);
                    http.abort();
                    processAnswer(json);
                } else {
                    console.error(
                                "status:", http.status,
                                "response:", http.response
                                );
                    http.abort();
                }
            }
        }

        console.log(method, request);
        http.open(method, request);
        http.send();
    }
}

function processCity(json) {
    var data = {};
    if (json !== undefined && json !== null) {
        json = json.results
        if (json.length !==undefined) {
            for (var i=0; i<json.length; i++) {
                var v = json[i];
                var d = {
                           "v_name": v.name,
                           "v_lat": v.latitude,
                           "v_lon": v.longitude,
                           };
                data[v.name] = d;
            }
        }
    } else {
        console.error("bad json")
    }

    return data;
}

function processWeather(json) {
    var data = {};
    var cw = {};

    var jcw = json["current_weather"];
    cw["v_temp"] = jcw["temperature"];
    cw["v_windspeed"] = jcw["windspeed"];
    cw["v_winddirection"] = jcw["winddirection"];
    cw["v_weathercode"] = jcw["weathercode"];
    data["v_current_weather"] = cw;

    return data;
}
