// ignore_for_file: constant_identifier_names

const GENERATE_TEMPLATE = r'''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0, user-scalable=no"
    />
    <title>{{ title }}</title>
    <style>
      body {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100vh;
        min-height: -webkit-fill-available;
        margin: 0;
        padding: 0;
        overflow: none;
        background-color: #eee;
      }
      button {
        padding: 20px;
        font-size: 20px;
        background-color: #0745c1;
        color: white;
        border-radius: 16px;
        border: none;
        cursor: pointer;
      }
      button:hover {
        box-shadow: 0 12px 16px 0 rgba(0, 0, 0, 0.24),
          0 17px 50px 0 rgba(0, 0, 0, 0.19);
      }
    </style>
  </head>
  <body>
    <progress indeterminate></progress>
    <button hidden>Download Presentation</button>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/pptxgenjs@3.3.1/libs/jszip.min.js"></script>
    <script src="https://cdn.jsdelivr.net/gh/gitbrent/pptxgenjs@3.3.1/dist/pptxgen.min.js"></script>
    <script>
      const btn = document.querySelector("button");
      const pgs = document.querySelector("progress");
      const dwn = document.querySelector("#download");
      function generate() {
        console.log('generate');
        const pptx = new PptxGenJS();
        pptx.layout = "{{ layout }}";
        pptx.title = `{{ title }}`;
        pptx.defineSlideMaster({
            title: "MASTER_SLIDE",
            background: { color: "000000" },
            slideNumber: { x: 0.3, y: "90%" },
        });
        let slide;
        {{{slides}}}
        const isMobile = '{{mobile}}';
        if (isMobile === 'true') {
          window.addEventListener('flutterInAppWebViewPlatformReady', async  () => {
              const data = await pptx.write("base64");
              window.flutter_inappwebview.callHandler('ping', data);
          });
        } else {
          pptx.writeFile("{{ title }}");
        }
      }
      document.body.onload = () => {
        generate();
        pgs.setAttribute("hidden", "");
        setTimeout(() => {
          btn.removeAttribute("hidden");
          btn.addEventListener("click", generate);
        }, 3000);
      };
    </script>
  </body>
</html>
''';

const GENERATE_SCRIPT = r'''
 function generate({ slides, title, layout }) {
  const pptx = new PptxGenJS();
  const newTitle = title ?? "Hymns for Worship";
  pptx.layout = layout ?? "LAYOUT_WIDE";
  pptx.title = newTitle;
  pptx.defineSlideMaster({
    title: "MASTER_SLIDE",
    background: { color: "000000" },
    slideNumber: { x: 0.3, y: "90%" },
  });
  for (const item of slides) {
    const slide = pptx.addSlide();
    if (item.text) {
      slide.addText(`${item.text}`, {
        x: `${item.x}`,
        y: `${item.y}`,
        color: `${item.textColor}`,
      });
      slide.background = {
        color: `${item.color}`,
      };
    } else if (item.image) {
      slide.background = {
        path: item.image,
        color: `${item.color}`,
      };
    } else if (item.data) {
      slide.background = {
        data: `image/png;base64,${item.data}`,
        color: `${item.color}`,
      };
    }
  }
  pptx.writeFile(newTitle);
}
window.addEventListener("generate", (e) => {
  const data = e.detail;
  generate(data);
});
''';

enum LayoutOptions {
  LAYOUT_16x9,
  LAYOUT_16x10,
  LAYOUT_4x3,
  LAYOUT_WIDE,
}

extension LayoutOptionsExtension on LayoutOptions {
  String get value {
    switch (this) {
      case LayoutOptions.LAYOUT_16x9:
        return "Layout (16:9)";
      case LayoutOptions.LAYOUT_16x10:
        return "Layout (16:10)";
      case LayoutOptions.LAYOUT_4x3:
        return "Layout (4:3)";
      case LayoutOptions.LAYOUT_WIDE:
        return "Layout (Wide)";
    }
  }

  double get ratio {
    switch (this) {
      case LayoutOptions.LAYOUT_16x9:
        return 16 / 9;
      case LayoutOptions.LAYOUT_16x10:
        return 16 / 10;
      case LayoutOptions.LAYOUT_4x3:
        return 4 / 3;
      case LayoutOptions.LAYOUT_WIDE:
        return 16 / 9;
    }
  }
}
