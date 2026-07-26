var baseUrl = jQuery("#base_url").val();

/************ Chunk Full Novel  ************/
var datafile = new plupload.Uploader({
    runtimes: "html5,flash,silverlight,html4",
    browse_button: "uploadFile", // you can pass in id...
    container: document.getElementById("container"), // ... or DOM Element itself
    chunk_size: "1mb",
    url: baseUrl + "/admin/novels/savechunk",
    max_file_count: 1,
    unique_names: true,
    send_file_name: true,
    multi_selection: false,
    filters: {
        mime_types: [{ title: "Content files", extensions: "pdf,epub" }],
        prevent_duplicates: true,
    },
    headers: {
        "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
    },
    init: {
        PostInit: function () {
            document.getElementById("filelist").innerHTML = "";
            document.getElementById("upload").onclick = function () {
                datafile.start();
                return false;
            };
        },
        FilesAdded: function (up, files) {
            while (up.files.length > 1) {
                up.removeFile(up.files[0]);
                document.getElementById("filelist").innerHTML = "";
            }
            plupload.each(files, function (file) {
                document.getElementById("filelist").innerHTML +=
                    '<div id="' +
                    file.id +
                    '">' +
                    file.name +
                    " (" +
                    plupload.formatSize(file.size) +
                    ") <b></b></div>";
            });
        },
        UploadProgress: function (up, file) {
            document
                .getElementById(file.id)
                .getElementsByTagName("b")[0].innerHTML =
                "<span>" + file.percent + "%</span>";
        },
        FileUploaded: function (up, file, info) {
            var response = JSON.parse(info.response);
            if (response.result) {
                jQuery("#novel_file_name").val(response.result);
            } else if (file.target_name) {
                jQuery("#novel_file_name").val(file.target_name);
            }
            toastr.success("File Uploaded");
        },
        Error: function (up, err) {
            document.getElementById("console").innerHTML +=
                "\nError #" + err.code + ": " + err.message;
        },
    },
});
datafile.init();
/***********************************************/

/************ Chunk Chapter  ************/
var datafile1 = new plupload.Uploader({
    runtimes: "html5,flash,silverlight,html4",
    browse_button: "uploadFile1", // you can pass in id...
    container: document.getElementById("container1"), // ... or DOM Element itself
    chunk_size: "1mb",
    url: baseUrl + "/admin/novels/chapters/savechunk",
    max_file_count: 1,
    unique_names: true,
    send_file_name: true,
    multi_selection: false,
    filters: {
        mime_types: [{ title: "Content files", extensions: "pdf,epub" }],
        prevent_duplicates: true,
    },
    headers: {
        "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
    },
    init: {
        PostInit: function () {
            document.getElementById("filelist1").innerHTML = "";
            document.getElementById("upload1").onclick = function () {
                datafile1.start();
                return false;
            };
        },
        FilesAdded: function (up, files) {
            while (up.files.length > 1) {
                up.removeFile(up.files[0]);
                document.getElementById("filelist1").innerHTML = "";
            }
            plupload.each(files, function (file) {
                document.getElementById("filelist1").innerHTML +=
                    '<div id="' +
                    file.id +
                    '">' +
                    file.name +
                    " (" +
                    plupload.formatSize(file.size) +
                    ") <b></b></div>";
            });
        },
        UploadProgress: function (up, file) {
            document
                .getElementById(file.id)
                .getElementsByTagName("b")[0].innerHTML =
                "<span>" + file.percent + "%</span>";
        },
        FileUploaded: function (up, file, info) {
            var response = JSON.parse(info.response);
            if (response.result) {
                jQuery("#chapter_file_name").val(response.result);
            } else if (file.target_name) {
                jQuery("#chapter_file_name").val(file.target_name);
            }
            toastr.success("File Uploaded");
        },
        Error: function (up, err) {
            document.getElementById("console1").innerHTML +=
                "\nError #" + err.code + ": " + err.message;
        },
    },
});
datafile1.init();
/***********************************************/

/************ Chunk Magazines  ************/
var datafile2 = new plupload.Uploader({
    runtimes: "html5,flash,silverlight,html4",
    browse_button: "uploadFile2", // you can pass in id...
    container: document.getElementById("container2"), // ... or DOM Element itself
    chunk_size: "1mb",
    url: baseUrl + "/admin/magazines/savechunk",
    max_file_count: 1,
    unique_names: true,
    send_file_name: true,
    multi_selection: false,
    filters: {
        mime_types: [{ title: "Content files", extensions: "pdf,epub" }],
        prevent_duplicates: true,
    },
    headers: {
        "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
    },
    init: {
        PostInit: function () {
            document.getElementById("filelist2").innerHTML = "";
            document.getElementById("upload2").onclick = function () {
                datafile2.start();
                return false;
            };
        },
        FilesAdded: function (up, files) {
            while (up.files.length > 1) {
                up.removeFile(up.files[0]);
                document.getElementById("filelist2").innerHTML = "";
            }
            plupload.each(files, function (file) {
                document.getElementById("filelist2").innerHTML +=
                    '<div id="' +
                    file.id +
                    '">' +
                    file.name +
                    " (" +
                    plupload.formatSize(file.size) +
                    ") <b></b></div>";
            });
        },
        UploadProgress: function (up, file) {
            document
                .getElementById(file.id)
                .getElementsByTagName("b")[0].innerHTML =
                "<span>" + file.percent + "%</span>";
        },
        FileUploaded: function (up, file, info) {
            var response = JSON.parse(info.response);
            if (response.result) {
                jQuery("#magazine_file_name").val(response.result);
            } else if (file.target_name) {
                jQuery("#magazine_file_name").val(file.target_name);
            }
            toastr.success("File Uploaded");
        },
        Error: function (up, err) {
            document.getElementById("console2").innerHTML +=
                "\nError #" + err.code + ": " + err.message;
        },
    },
});
datafile2.init();
/***********************************************/

/************ Chunk Audio Book  ************/
var datafile3 = new plupload.Uploader({
    runtimes: "html5,flash,silverlight,html4",
    browse_button: "uploadFile3", // you can pass in id...
    container: document.getElementById("container3"), // ... or DOM Element itself
    chunk_size: "1mb",
    url: baseUrl + "/admin/audiobooks/savechunk",
    max_file_count: 1,
    unique_names: true,
    send_file_name: true,
    multi_selection: false,
    filters: {
        mime_types: [{ title: "Content files", extensions: "mp3" }],
        prevent_duplicates: true,
    },
    headers: {
        "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
    },
    init: {
        PostInit: function () {
            document.getElementById("filelist3").innerHTML = "";
            document.getElementById("upload3").onclick = function () {
                datafile3.start();
                return false;
            };
        },
        FilesAdded: function (up, files) {
            while (up.files.length > 1) {
                up.removeFile(up.files[0]);
                document.getElementById("filelist3").innerHTML = "";
            }
            plupload.each(files, function (file) {
                document.getElementById("filelist3").innerHTML +=
                    '<div id="' +
                    file.id +
                    '">' +
                    file.name +
                    " (" +
                    plupload.formatSize(file.size) +
                    ") <b></b></div>";
            });
        },
        UploadProgress: function (up, file) {
            document
                .getElementById(file.id)
                .getElementsByTagName("b")[0].innerHTML =
                "<span>" + file.percent + "%</span>";
        },
        FileUploaded: function (up, file, info) {
            var response = JSON.parse(info.response);
            if (response.result) {
                jQuery("#full_audio_file_name").val(response.result);
            } else if (file.target_name) {
                jQuery("#full_audio_file_name").val(file.target_name);
            }
            toastr.success("File Uploaded");
        },
        Error: function (up, err) {
            document.getElementById("console3").innerHTML +=
                "\nError #" + err.code + ": " + err.message;
        },
    },
});
datafile3.init();
/***********************************************/

/************ Chunk Episode  ************/
var datafile4 = new plupload.Uploader({
    runtimes: "html5,flash,silverlight,html4",
    browse_button: "uploadFile4", // you can pass in id...
    container: document.getElementById("container4"), // ... or DOM Element itself
    chunk_size: "1mb",
    url: baseUrl + "/admin/audiobooks/episode/savechunk",
    max_file_count: 1,
    unique_names: true,
    send_file_name: true,
    multi_selection: false,
    filters: {
        mime_types: [{ title: "Content files", extensions: "mp3" }],
        prevent_duplicates: true,
    },
    headers: {
        "X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
    },
    init: {
        PostInit: function () {
            document.getElementById("filelist4").innerHTML = "";
            document.getElementById("upload4").onclick = function () {
                datafile4.start();
                return false;
            };
        },
        FilesAdded: function (up, files) {
            while (up.files.length > 1) {
                up.removeFile(up.files[0]);
                document.getElementById("filelist4").innerHTML = "";
            }
            plupload.each(files, function (file) {
                document.getElementById("filelist4").innerHTML +=
                    '<div id="' +
                    file.id +
                    '">' +
                    file.name +
                    " (" +
                    plupload.formatSize(file.size) +
                    ") <b></b></div>";
            });
        },
        UploadProgress: function (up, file) {
            document
                .getElementById(file.id)
                .getElementsByTagName("b")[0].innerHTML =
                "<span>" + file.percent + "%</span>";
        },
        FileUploaded: function (up, file, info) {
            var response = JSON.parse(info.response);
            if (response.result) {
                jQuery("#audio_file_name").val(response.result);
            } else if (file.target_name) {
                jQuery("#audio_file_name").val(file.target_name);
            }
            toastr.success("File Uploaded");
        },
        Error: function (up, err) {
            document.getElementById("console4").innerHTML +=
                "\nError #" + err.code + ": " + err.message;
        },
    },
});
datafile4.init();
/***********************************************/
