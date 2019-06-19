const EnableFilenameForUploads = () => {
  $("input.custom-file-input[type=file]").on("change", function(e) {
    // The issue is that the files list isn't actually an array. So we can't map it
    let files = [];
    let i = 0;
    while (i < e.target.files.length) {
      files.push(e.target.files[i].name);
      i++;
    }
    $(this)
      .next(".custom-file-label")
      .text(files.join(", "));
  });
};

export default enableFilenameForUploads;
