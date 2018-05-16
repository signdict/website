import browser from 'detect-browser';

function getMediaConstraint() {
  let constraints = {audio: true, video: true};

  if (browser.name == "firefox") {
    constraints = {
      video: {
        height: { min: 240, ideal: 720, max: 720 },
        width: { min: 320, ideal: 1280, max: 1280 },
      },
      audio: false
    };
  } else if (browser.name == "chrome") {
    constraints = {
      video: {
        mandatory: {
          maxHeight: 720,
          maxWidth: 1280
        },
        optional: [
          {minWidth: 320},
          {minWidth: 640},
          {minWidth: 960},
          {minWidth: 1024},
          {minWidth: 1280}
        ]
      },
      audio: false
    }
  }

  return constraints;
}

export { getMediaConstraint }
