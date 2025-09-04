const https = require('https');
const fs = require('fs');

https.get({
    hostname:'api.github.com',
    path:'/',
    method:'GET',
    headers:{
        'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
    }
}, (res) => {
    let data = '';

    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        const context = process.env.context;
        const config = JSON.parse(data);
        console.log('\x1b[33m%s\x1b[0m', config);
        let command;
        switch (context) {
            case 'release':
                command = `MY_ENV_VAR=${config} fvm flutter build apk --obfuscate --split-debug-info=HLQ_Struggle`
                break;
            case 'dev':
                command = "fvm flutter run"
                break;
            default:
                break;

        }
        // 使用 shell 命令传入 flutter build
        require('child_process').execSync(
            command,
            { stdio: 'inherit' }
        );
    });
}).on('error', (e) => {
    console.error(e);
});