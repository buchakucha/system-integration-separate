const axios = require('axios');
const jenkinsapi = require('jenkins-api');

const getUsIds = async () => {
    const { data } = await axios.get("http://192.168.1.106:9000/api/v1/userstories");

    return data.filter(us => us.status_extra_info.name === "Ready for test").map(us => us.id);
}

const getContextById = async (id) => {
    const { data } = await axios.get(`http://192.168.1.106:9000/api/v1/userstories/${id}`);
    const [token, pipelineName] = data.description.toString().split(' ');

    return { token, pipelineName };
}

const runPipelineByUrl = async (token, pipelineName) => {
    let jenkins = jenkinsapi.init(`http://admin:${token}@192.168.1.106:8080`);
    jenkins.build(pipelineName, function (err, data) {
        if (err) { return console.log(err); }
        console.log(data)
    });
}

let memoId = new Set();

setInterval(async () => {
    try {
        const userStoryIds = await getUsIds() || [];
        const newIds = userStoryIds.filter(id => !memoId.has(id));
        if (!newIds.length) {
            console.log("No one new")
        }
        memoId = new Set(userStoryIds);
        for (id of newIds) {
            const { token, pipelineName } = await getContextById(id);
            runPipelineByUrl(token, pipelineName);
        }
    } catch (err) {
        console.log(err);
    }
}, 60 * 1000)
