


[TO DO] Update agent context.










-----------------------







Create a .bash file in the @local-sgtm/nodejs-server-files-debugging that must do the following when executed:

- It should run only when the .env variable DEBUGGING_ENABLED is true. Otherwise, do nothing.

- Run the command "docker cp gtm-live:/app/server_bin.js ./nodejs-server-files-debugging"

- Download "https://www.googletagmanager.com/static/serverjs/server_bootstrap.js" and put in the "server_bootstrap.js" file
- Download "https://www.googletagmanager.com/server.js?id={atob(CONTAINER_CONFIG .env variable).id}&gtm_preview=env-{atob(CONTAINER_CONFIG .env variable).env}&gtm_auth={atob(CONTAINER_CONFIG .env variable).auth}" and put in the"server.js?live" file

Example, if CONTAINER_CONFIG=aWQ9R1RNLU5XOEhRR0pEJmVudj0xJmF1dGg9OTA0X2Zkei14YjQ3akgtdzJvdU1zdw==, the URL will be "https://www.googletagmanager.com/server.js?id=GTM-NW8HQGJD&gtm_preview=env-1&gtm_auth=904_fdz-xb47jH-w2ouMsw" after decoding CONTAINER_CONFIG and accessing its contents.

- Download "https://www.googletagmanager.com/server.js?id={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).id}&gtm_preview={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).gtm_preview}&gtm_auth={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).gtm_auth}" and put in the "server.js?preview"
  - For building the https://www.googletagmanager.com/server.js URL: if GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable is set, use it. Otherwise, parse from the the CONTAINER_CONFIG.

GTM_PREVIEW_PARAMS_STRING_OR_HEADER= # 'https://{sGTM Domain}/gtm/debug?id=GTM-WKTQ2HZ7&gtm_auth=bX0FTZzmxMkkA9AsIE2tlg&gtm_preview=19&hl=en' (sGTM Preview Mode URL) or 'aWQAAARNLU5IWEg1Sk40JmVudj0xJmF1dGg9SVZYaVlxTEVGRTB6T2Q4VmJBV05KUQ==' (X-Gtm-Preview-Header)

Example, if the GTM_PREVIEW_PARAMS_STRING_OR_HEADER='https://{sGTM Domain}/gtm/debug?id=GTM-WKTQ2HZ7&gtm_auth=bX0FTZzmxMkkA9AsIE2tlg&gtm_preview=19&hl=en' (for sGTM Preview Mode URL) or GTM_PREVIEW_PARAMS_STRING_OR_HEADER=aWQAAARNLU5IWEg1Sk40JmVudj0xJmF1dGg9SVZYaVlxTEVGRTB6T2Q4VmJBV05KUQ== (for X-Gtm-Preview-Header), the URL will be "https://www.googletagmanager.com/server.js?id=GTM-WKTQ2HZ7&gtm_preview=env-19&gtm_auth=bX0FTZzmxMkkA9AsIE2tlg" after parsing or decoding the GTM_PREVIEW_PARAMS_STRING_OR_HEADER and accessing its contents.

- Add this code to the top of the file server_bin.js after "use strict;"
```
/* Modification - Start */

const http = require('http');
const https = require('https');
const { URL, URLSearchParams } = require('url');
const process = require('process');
function logRequest(options, ...args) {
  console.log(
    `${new Date().toString()}`,
    `[${process.env.RUN_AS_PREVIEW_SERVER ? 'Preview Server' : 'Live Server'}]`,
    '[HTTP REQUEST]',
    options
  );
  return options;
}
function attachRequestBodyLogger(req) {
  const originalWrite = req.write;
  req.write = function (chunk, ...writeArgs) {
    console.log(
      '[Request] Intercepted write body chunk:',
      chunk ? `${chunk.toString().slice(0, 100)}...` : ''
    );
    return originalWrite.call(this, chunk, ...writeArgs);
  };
  const originalEnd = req.end;
  req.end = function (chunk, ...writeArgs) {
    if (
      (chunk && typeof chunk !== 'function' && typeof chunk !== 'string') ||
      (typeof chunk === 'string' && chunk.length > 0)
    ) {
      console.log(
        '[Request] Intercepted end body chunk:',
        `${chunk.toString().slice(0, 100)}...`
      );
    }
    return originalEnd.call(this, chunk, ...writeArgs);
  };
}
function getGtmReplacement(options) {
  try {
    let hostname, pathname, search;
    const isString = typeof options === 'string';
    const isUrl = options instanceof URL;
    if (isString) {
      const u = new URL(options);
      hostname = u.hostname;
      pathname = u.pathname;
      search = u.search;
    } else if (isUrl) {
      hostname = options.hostname;
      pathname = options.pathname;
      search = options.search;
    } else {
      hostname = options.hostname || options.host;
      pathname = options.path ? options.path.split('?')[0] : '/';
      const qIndex = options.path ? options.path.indexOf('?') : -1;
      search = qIndex !== -1 ? options.path.substring(qIndex) : '';
    }
    if (hostname === 'www.googletagmanager.com') {
      let newPath = null;
      // Match Server Bootstrap
      if (
        pathname === '/static/serverjs/server_bootstrap.js' ||
        pathname === '/static/serverjs/latest/server_bootstrap.js'
      ) {
        newPath = '/server_bootstrap.js';
      }
      // Match Server JS
      else if (pathname === '/server.js') {
        const queryParams = new URLSearchParams(search);

        // 1. Live Config Parsing
        let liveConfig = {};
        if (process.env.CONTAINER_CONFIG) {
          try {
            const decoded = Buffer.from(process.env.CONTAINER_CONFIG, 'base64').toString('utf-8');
            const params = new URLSearchParams(decoded);
            liveConfig = {
              id: params.get('id'),
              env: params.get('env'), // e.g. "1"
              auth: params.get('auth')
            };
          } catch (e) {}
        }
        // 2. Preview Config Parsing
        let previewConfig = {};
        const rawPreview = process.env.GTM_PREVIEW_PARAMS_STRING_OR_HEADER;
        if (rawPreview) {
             let params;
             try {
                if (rawPreview.startsWith('http')) {
                    const u = new URL(rawPreview);
                    params = u.searchParams;
                } else {
                    const decoded = Buffer.from(rawPreview, 'base64').toString('utf-8');
                    // Check if it's a query string
                    if (decoded.includes('=')) {
                        params = new URLSearchParams(decoded);
                    }
                }
             } catch(e) {}
             if (params) {
                const pId = params.get('id');
                const pAuth = params.get('gtm_auth') || params.get('auth');
                let pPreview = params.get('gtm_preview');
                const pEnv = params.get('env');
                // Normalize gtm_preview
                if (pPreview) {
                   // If numeric "19", prepend "env-" -> "env-19"
                   if (pPreview.match(/^\d+$/)) {
                       pPreview = `env-${pPreview}`;
                   }
                } else if (pEnv) {
                   pPreview = `env-${pEnv}`;
                }

                previewConfig = {
                    id: pId,
                    gtm_preview: pPreview,
                    gtm_auth: pAuth
                };
             }
        }
        // 3. Match Request
        const reqId = queryParams.get('id');
        const reqPreview = queryParams.get('gtm_preview');
        const reqAuth = queryParams.get('gtm_auth');
        // Check Live
        // expected match: id={id}, gtm_preview=env-{env}, gtm_auth={auth}
        if (liveConfig.id && liveConfig.env && liveConfig.auth) {
             if (reqId === liveConfig.id &&
                 reqPreview === `env-${liveConfig.env}` &&
                 reqAuth === liveConfig.auth) {
                 newPath = '/server.js?live';
             }
        }
        // Check Preview
        // expected match: id={pId}, gtm_preview={pPreview}, gtm_auth={pAuth}
        if (!newPath && previewConfig.id && previewConfig.gtm_preview && previewConfig.gtm_auth) {
             if (reqId === previewConfig.id &&
                 reqPreview === previewConfig.gtm_preview &&
                 reqAuth === previewConfig.gtm_auth) {
                 newPath = '/server.js?preview';
             }
        }
      }
      if (newPath) {
        if (isString) {
          return `http://localhost:9000${newPath}`;
        }
        if (isUrl) {
          return new URL(`http://localhost:9000${newPath}`);
        }
        return {
          ...options,
          protocol: 'http:',
          hostname: 'localhost',
          port: 9000,
          path: newPath,
        };
      }
    }
  } catch (e) {
    // Ignore parsing errors to prevent crashes in interception
  }
  return null;
}
const originalHttpGet = http.get;
http.get = function (options, ...args) {
  logRequest(options, ...args);
  const replacement = getGtmReplacement(options);
  // If replacing to http-local, ensure we call http.get, not https.get
  if (replacement) {
      return originalHttpGet.call(this, replacement, ...args);
  }
  return originalHttpGet.call(this, options, ...args);
};
const originalHttpsGet = https.get;
https.get = function (options, ...args) {
  logRequest(options, ...args);
  const replacement = getGtmReplacement(options);

  // If redirected to http, switch to the http agent (originalHttpGet)
  const isHttpRedirect = replacement && (
    (typeof replacement === 'string' && replacement.startsWith('http:') && !replacement.startsWith('https:')) ||
    (replacement instanceof URL && replacement.protocol === 'http:') ||
    (replacement.protocol === 'http:')
  );
  if (isHttpRedirect) {
    return originalHttpGet.call(this, replacement, ...args);
  }
  return originalHttpsGet.call(this, replacement || options, ...args);
};
const originalHttpRequest = http.request;
http.request = function (options, ...args) {
  logRequest(options, ...args);
  const replacement = getGtmReplacement(options);
  const req = originalHttpRequest.call(this, replacement || options, ...args);
  attachRequestBodyLogger(req);
  return req;
};
const originalHttpsRequest = https.request;
https.request = function (options, ...args) {
  logRequest(options, ...args);
  const replacement = getGtmReplacement(options);

  let req;
  const isHttpRedirect = replacement && (
    (typeof replacement === 'string' && replacement.startsWith('http:') && !replacement.startsWith('https:')) ||
    (replacement instanceof URL && replacement.protocol === 'http:') ||
    (replacement.protocol === 'http:')
  );
  if (isHttpRedirect) {
    req = originalHttpRequest.call(this, replacement, ...args);
  } else {
    req = originalHttpsRequest.call(this, replacement || options, ...args);
  }

  attachRequestBodyLogger(req);
  return req;
};

/* Modification - End */
```

- In the modified server_bin.js change to code of the monkey-patched http.get, https.get, http.request and https.request functions to whenever there's a request to "www.googletagmanager.com/static/serverjs/server_bootstrap.js" or "www.googletagmanager.com/static/serverjs/latest/server_bootstrap.js", serve from "http://localhost:9000/server_bootstrap.js"
- In the modified server_bin.js change to code of the monkey-patched http.get, https.get, http.request and https.request functions to whenever there's a request to "www.googletagmanager.com/server.js?id={atob(CONTAINER_CONFIG .env variable).id}&gtm_preview=env-{atob(CONTAINER_CONFIG .env variable).env}&gtm_auth={atob(CONTAINER_CONFIG .env variable).auth}" (Live) serve from "http://localhost:9000/server.js?live"; to and "www.googletagmanager.com/server.js?id={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).id}&gtm_preview={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).gtm_preview}&gtm_auth={query(Preview URL from GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable) or atob(GTM_PREVIEW_PARAMS_STRING_OR_HEADER .env variable).gtm_auth}" (Preview) serve from "http://localhost:9000/server.js?preview"


- Run this in the Docker Containers named "gtm-live" and "gtm-preview" to create a local server for serving the localhost file in the Docker Container. :
  docker exec gtm-live /nodejs/bin/node -e "const http = require('http'), fs = require('fs'), path = require('path'); http.createServer((req, res) => { const filePath = '.' + req.url; fs.readFile(filePath, (err, data) => { if (err) { res.writeHead(404); res.end('Not Found'); return; } res.writeHead(200); res.end(data); }); }).listen(9000); console.log('Serving at http://localhost:9000');"

- Run these commands to copy the modified files to the Docker Containers
  - docker cp ./nodejs-server-files-debugging/server.js?live gtm-live:/app/server.js?live
  - docker cp ./nodejs-server-files-debugging/server.js?preview gtm-live:/app/server.js?preview
  - docker cp ./nodejs-server-files-debugging/server_bootstrap.js gtm-live:/app/server_bootstrap.js
  - docker cp ./nodejs-server-files-debugging/server_bootstrap.js gtm-preview:/app/server_bootstrap.js
  - docker cp ./nodejs-server-files-debugging/server_bin.js gtm-live:/app/server_bin.js
  - docker cp ./nodejs-server-files-debugging/server_bin.js gtm-preview:/app/server_bin.js

- Run a command to restart the Docker Containers "gtm-live" and "gtm-preview"