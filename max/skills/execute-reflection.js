#!/usr/bin/env node

/**
 * Max 自我反省执行脚本
 *
 * 功能：
 * 1. 分析当前会话中的错误
 * 2. 生成反思报告
 * 3. 自动更新CLAUDE.md文件
 * 4. 记录学习成果到reflection-log.json
 *
 * 用法：
 *   node execute-reflection.js analyze <error-type> <description>
 *   node execute-reflection.js report
 *   node execute-reflection.js update-rules <error-id>
 *   node execute-reflection.js stats
 *   node execute-reflection.js calibrate <estimated> <actual>
 */

const fs = require('fs');
const path = require('path');

// 路径配置
const BASE_DIR = path.resolve(__dirname, '..');
const PATHS = {
  reflectionLog: path.join(BASE_DIR, 'memory', 'reflection-log.json'),
  reflectionPatterns: path.join(__dirname, 'reflection-patterns.json'),
  claudeMd: path.join(BASE_DIR, 'CLAUDE.md'),
  violationsLog: path.join(BASE_DIR, 'memory', 'violations.log'),
};

// 确保目录存在
function ensureDir(filePath) {
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// 读取JSON文件（带默认值）
function readJson(filePath, defaultValue) {
  try {
    if (fs.existsSync(filePath)) {
      return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    }
  } catch (e) {
    console.error(`[WARN] 读取 ${filePath} 失败: ${e.message}`);
  }
  return defaultValue;
}

// 写入JSON文件
function writeJson(filePath, data) {
  ensureDir(filePath);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
}

// 生成错误ID
function generateErrorId() {
  const now = new Date();
  const date = now.toISOString().slice(0, 10).replace(/-/g, '');
  const seq = String(Math.floor(Math.random() * 999) + 1).padStart(3, '0');
  return `ERR-${date}-${seq}`;
}

// 获取当前日期时间
function nowISO() {
  return new Date().toISOString();
}

// ==================== 核心功能 ====================

/**
 * 分析错误并记录
 */
function analyzeError(errorType, description, context = {}) {
  const patterns = readJson(PATHS.reflectionPatterns, { error_categories: {}, historical_errors: [] });
  const log = readJson(PATHS.reflectionLog, { errors: [], stats: {}, last_review: null });

  // 解析错误类型
  const [mainType, subType] = parseErrorType(errorType);
  const category = patterns.error_categories[mainType];

  if (!category) {
    console.error(`[ERROR] 未知错误类型: ${errorType}`);
    console.log('可用类型: E-TOKEN, E-AUTH, E-SCOPE, E-FLOW, E-LOGIC, E-TOOL');
    process.exit(1);
  }

  const errorId = generateErrorId();

  // 构建错误记录
  const errorRecord = {
    id: errorId,
    date: nowISO(),
    category: errorType,
    severity: category.severity,
    description: description,
    context: {
      task_description: context.task || '未提供',
      estimated_tokens: context.estimated || null,
      actual_tokens: context.actual || null,
      deviation_ratio: (context.estimated && context.actual)
        ? (context.actual / context.estimated).toFixed(2)
        : null,
    },
    root_cause: null,
    resolution: {
      immediate: null,
      rule_added: null,
      prevention: null,
    },
    status: 'pending_analysis',
    lessons_learned: null,
  };

  // 自动填充Token偏差分析
  if (mainType === 'E-TOKEN' && context.estimated && context.actual) {
    const ratio = context.actual / context.estimated;
    errorRecord.root_cause = ratio > 1.5
      ? `Token预估偏低${((ratio - 1) * 100).toFixed(0)}%，可能原因：任务复杂度低估、未考虑多文件累积消耗、校准系数未应用`
      : `Token预估偏高${((1 - ratio) * 100).toFixed(0)}%，可能原因：任务实际比预期简单`;

    errorRecord.resolution.prevention = `更新校准系数，当前偏差比: ${ratio.toFixed(2)}x`;
  }

  // 自动填充授权违规分析
  if (mainType === 'E-AUTH') {
    errorRecord.root_cause = '授权检查步骤被跳过或未正确执行';
    errorRecord.resolution.immediate = '立即停止操作，向用户道歉并请求授权';
    errorRecord.resolution.prevention = '在操作执行前增加强制授权验证检查点';
  }

  // 记录到日志
  log.errors.push(errorRecord);

  // 更新统计
  if (!log.stats[mainType]) {
    log.stats[mainType] = { count: 0, last_occurrence: null };
  }
  log.stats[mainType].count += 1;
  log.stats[mainType].last_occurrence = nowISO();

  writeJson(PATHS.reflectionLog, log);

  // 同时记录到patterns的historical_errors
  patterns.historical_errors.push(errorRecord);
  writeJson(PATHS.reflectionPatterns, patterns);

  // 输出反思报告
  console.log('');
  console.log('='.repeat(60));
  console.log('  自我反思报告');
  console.log('='.repeat(60));
  console.log('');
  console.log(`错误ID:   ${errorId}`);
  console.log(`类型:     ${errorType} (${category.name})`);
  console.log(`严重度:   ${category.severity}`);
  console.log(`描述:     ${description}`);
  console.log(`时间:     ${errorRecord.date}`);
  console.log('');

  if (errorRecord.context.deviation_ratio) {
    console.log(`Token偏差: 预估${context.estimated} vs 实际${context.actual} (${errorRecord.context.deviation_ratio}x)`);
    console.log('');
  }

  if (errorRecord.root_cause) {
    console.log(`根本原因: ${errorRecord.root_cause}`);
    console.log('');
  }

  // 查找改进模板
  const templateKey = Object.keys(patterns.improvement_templates || {}).find(
    k => patterns.improvement_templates[k].applies_to === mainType
  );
  if (templateKey) {
    const template = patterns.improvement_templates[templateKey].template;
    console.log('建议改进措施:');
    console.log(`  即时修复:   ${template.immediate_action}`);
    console.log(`  规则更新:   ${template.rule_update}`);
    console.log(`  检测增强:   ${template.detection_enhancement}`);
    console.log(`  预防措施:   ${template.prevention}`);
    console.log('');
  }

  console.log('='.repeat(60));
  console.log(`记录已保存到: ${PATHS.reflectionLog}`);
  console.log('');

  return errorId;
}

/**
 * 生成统计报告
 */
function generateStats() {
  const log = readJson(PATHS.reflectionLog, { errors: [], stats: {} });
  const patterns = readJson(PATHS.reflectionPatterns, { error_categories: {} });

  console.log('');
  console.log('='.repeat(60));
  console.log('  错误统计报告');
  console.log('='.repeat(60));
  console.log('');

  const totalErrors = log.errors.length;
  console.log(`总错误数: ${totalErrors}`);
  console.log('');

  if (totalErrors === 0) {
    console.log('暂无错误记录。');
    return;
  }

  // 按类型统计
  console.log('按类型分布:');
  console.log('-'.repeat(40));
  for (const [type, data] of Object.entries(log.stats)) {
    const cat = patterns.error_categories[type];
    const catName = (cat && cat.name) ? cat.name : type;
    const lastOcc = data.last_occurrence ? data.last_occurrence.slice(0, 10) : '未知';
    console.log(`  ${type} (${catName}): ${data.count}次 | 最近: ${lastOcc}`);
  }
  console.log('');

  // 按严重度统计
  const severityCounts = { critical: 0, high: 0, medium: 0, low: 0 };
  log.errors.forEach(err => {
    const mainType = err.category.split('-').slice(0, 2).join('-');
    const mainCat = patterns.error_categories[mainType];
    const severity = (mainCat && mainCat.severity) ? mainCat.severity : 'unknown';
    if (severityCounts[severity] !== undefined) {
      severityCounts[severity]++;
    }
  });
  console.log('按严重度分布:');
  console.log('-'.repeat(40));
  console.log(`  严重(critical): ${severityCounts.critical}`);
  console.log(`  高(high):       ${severityCounts.high}`);
  console.log(`  中(medium):     ${severityCounts.medium}`);
  console.log(`  低(low):        ${severityCounts.low}`);
  console.log('');

  // 未解决的错误
  const pending = log.errors.filter(e => e.status === 'pending_analysis');
  if (pending.length > 0) {
    console.log(`待分析错误: ${pending.length}条`);
    pending.forEach(e => {
      console.log(`  - ${e.id}: ${e.description}`);
    });
    console.log('');
  }

  // Token偏差趋势
  const tokenErrors = log.errors.filter(e => e.category.startsWith('E-TOKEN') && e.context.deviation_ratio);
  if (tokenErrors.length > 0) {
    const avgDeviation = tokenErrors.reduce((sum, e) => sum + parseFloat(e.context.deviation_ratio), 0) / tokenErrors.length;
    console.log(`Token估算平均偏差比: ${avgDeviation.toFixed(2)}x`);
    console.log('');
  }

  console.log('='.repeat(60));
}

/**
 * 生成完整反思报告
 */
function generateReport() {
  const log = readJson(PATHS.reflectionLog, { errors: [], stats: {} });

  console.log('');
  console.log('='.repeat(60));
  console.log('  完整反思报告');
  console.log('='.repeat(60));
  console.log('');

  if (log.errors.length === 0) {
    console.log('暂无错误记录。');
    return;
  }

  log.errors.forEach((err, idx) => {
    console.log(`--- 错误 #${idx + 1} ---`);
    console.log(`ID:       ${err.id}`);
    console.log(`日期:     ${err.date}`);
    console.log(`类型:     ${err.category}`);
    console.log(`严重度:   ${err.severity}`);
    console.log(`描述:     ${err.description}`);
    console.log(`状态:     ${err.status}`);

    if (err.root_cause) {
      console.log(`根因:     ${err.root_cause}`);
    }
    if (err.lessons_learned) {
      console.log(`教训:     ${err.lessons_learned}`);
    }

    if (err.context.deviation_ratio) {
      console.log(`Token偏差: ${err.context.deviation_ratio}x (预估${err.context.estimated_tokens} / 实际${err.context.actual_tokens})`);
    }

    console.log('');
  });

  console.log('='.repeat(60));
}

/**
 * Token估算校准
 */
function calibrateTokens(estimated, actual) {
  const patterns = readJson(PATHS.reflectionPatterns, { calibration_data: {} });
  const calData = patterns.calibration_data;
  const calibration = (calData && calData.token_estimation) ? calData.token_estimation : {};

  const ratio = actual / estimated;

  console.log('');
  console.log('='.repeat(60));
  console.log('  Token估算校准');
  console.log('='.repeat(60));
  console.log('');
  console.log(`预估值:   ${estimated} tokens`);
  console.log(`实际值:   ${actual} tokens`);
  console.log(`偏差比:   ${ratio.toFixed(2)}x`);
  console.log(`偏差率:   ${((ratio - 1) * 100).toFixed(1)}%`);
  console.log('');

  if (ratio > 1.5) {
    console.log('诊断: 严重低估 - 需要提高校准系数');
    console.log('');
    console.log('建议校准调整:');

    const baselines = calibration.task_type_baselines || {};
    for (const [type, data] of Object.entries(baselines)) {
      const newCoeff = Math.min(3.0, Math.max(0.5, 0.7 * data.coefficient + 0.3 * ratio));
      console.log(`  ${type}: ${data.coefficient} -> ${newCoeff.toFixed(2)}`);
    }
  } else if (ratio < 0.5) {
    console.log('诊断: 严重高估 - 可以降低校准系数');
  } else {
    console.log('诊断: 估算在合理范围内');
  }

  console.log('');
  console.log('='.repeat(60));

  // 如果严重偏差，自动记录错误
  if (ratio > 1.5 || ratio < 0.5) {
    const errorType = ratio > 1.5 ? 'E-TOKEN-LOW' : 'E-TOKEN-HIGH';
    const desc = `Token估算偏差: 预估${estimated}, 实际${actual} (${ratio.toFixed(2)}x)`;
    analyzeError(errorType, desc, { estimated, actual });
  }
}

/**
 * 更新CLAUDE.md中的学习记录
 */
function updateClaudeMd(errorId) {
  const log = readJson(PATHS.reflectionLog, { errors: [] });
  const error = log.errors.find(e => e.id === errorId);

  if (!error) {
    console.error(`[ERROR] 未找到错误记录: ${errorId}`);
    process.exit(1);
  }

  // 读取当前CLAUDE.md
  let claudeContent = fs.readFileSync(PATHS.claudeMd, 'utf8');

  // 检查是否已有学习记录章节
  const learningHeader = '## 学习记录（自我反省系统自动维护）';
  if (!claudeContent.includes(learningHeader)) {
    // 在文件末尾添加学习记录章节
    claudeContent += `\n\n${learningHeader}\n\n`;
  }

  // 构建新的学习条目
  const date = error.date.slice(0, 10);
  const entry = [
    `### ${date} - ${error.id}`,
    `**错误**: ${error.category} - ${error.description}`,
    `**根因**: ${error.root_cause || '待分析'}`,
    `**新规则**: ${(error.resolution && error.resolution.rule_added) ? error.resolution.rule_added : '待制定'}`,
    `**预防**: ${(error.resolution && error.resolution.prevention) ? error.resolution.prevention : '待制定'}`,
    `**状态**: ${error.status}`,
    '',
  ].join('\n');

  // 在学习记录章节末尾添加
  const headerIndex = claudeContent.indexOf(learningHeader);
  const insertPos = headerIndex + learningHeader.length + 2;
  claudeContent = claudeContent.slice(0, insertPos) + entry + '\n' + claudeContent.slice(insertPos);

  fs.writeFileSync(PATHS.claudeMd, claudeContent, 'utf8');

  // 更新错误状态
  error.status = 'rule_updated';
  writeJson(PATHS.reflectionLog, log);

  console.log('');
  console.log(`CLAUDE.md 已更新 - 添加学习记录: ${errorId}`);
  console.log(`错误状态已更新为: rule_updated`);
  console.log('');
}

// ==================== 辅助函数 ====================

function parseErrorType(errorType) {
  const parts = errorType.split('-');
  const mainType = parts.slice(0, 2).join('-');
  const subType = parts.length > 2 ? errorType : null;
  return [mainType, subType];
}

function printUsage() {
  console.log(`
Max 自我反省执行脚本
====================

用法:
  node execute-reflection.js <command> [arguments]

命令:
  analyze <error-type> <description>    分析并记录错误
    可选参数（通过环境变量传递）:
      ESTIMATED=<num>  预估token数
      ACTUAL=<num>     实际token数

  report                                 生成完整反思报告

  stats                                  显示错误统计

  calibrate <estimated> <actual>         Token估算校准

  update-rules <error-id>               将错误学习成果更新到CLAUDE.md

错误类型:
  E-TOKEN-LOW    Token严重低估
  E-TOKEN-HIGH   Token严重高估
  E-TOKEN-MISS   未进行Token估算
  E-AUTH-OPUS    Opus未授权使用
  E-AUTH-GIT     Git操作未授权
  E-AUTH-BOUNDARY 职责越界
  E-SCOPE-OVER   过度设计
  E-SCOPE-UNDER  交付不足
  E-FLOW-SKIP    检查点跳过
  E-FLOW-ORDER   检查点顺序错误
  E-LOGIC-ANALYSIS 分析推理错误
  E-LOGIC-DECISION 决策错误
  E-TOOL-WRONG   工具选择错误
  E-TOOL-MISUSE  工具参数错误

示例:
  node execute-reflection.js analyze E-TOKEN-LOW "估算3000实际17000"
  ESTIMATED=3000 ACTUAL=17000 node execute-reflection.js analyze E-TOKEN-LOW "描述"
  node execute-reflection.js calibrate 3000 17000
  node execute-reflection.js stats
  node execute-reflection.js update-rules ERR-20260219-001
  `);
}

// ==================== 主入口 ====================

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    printUsage();
    process.exit(0);
  }

  const command = args[0];

  switch (command) {
    case 'analyze': {
      if (args.length < 3) {
        console.error('[ERROR] 用法: analyze <error-type> <description>');
        process.exit(1);
      }
      const errorType = args[1];
      const description = args.slice(2).join(' ');
      const context = {
        estimated: process.env.ESTIMATED ? parseInt(process.env.ESTIMATED) : null,
        actual: process.env.ACTUAL ? parseInt(process.env.ACTUAL) : null,
        task: process.env.TASK || null,
      };
      analyzeError(errorType, description, context);
      break;
    }

    case 'report':
      generateReport();
      break;

    case 'stats':
      generateStats();
      break;

    case 'calibrate': {
      if (args.length < 3) {
        console.error('[ERROR] 用法: calibrate <estimated> <actual>');
        process.exit(1);
      }
      calibrateTokens(parseInt(args[1]), parseInt(args[2]));
      break;
    }

    case 'update-rules': {
      if (args.length < 2) {
        console.error('[ERROR] 用法: update-rules <error-id>');
        process.exit(1);
      }
      updateClaudeMd(args[1]);
      break;
    }

    default:
      console.error(`[ERROR] 未知命令: ${command}`);
      printUsage();
      process.exit(1);
  }
}

main();
