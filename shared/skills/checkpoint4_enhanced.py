#!/usr/bin/env python3
"""
Checkpoint 4 Enhanced - 智能Skill发现集成
将SkillDiscoveryEngine、SkillMatcher、SkillMarketClient集成到检查点4
"""

import os
import sys
import re
import time
import json
from typing import List, Dict, Tuple, Optional, Any
from pathlib import Path

# ─────────────────────────────────────────────
# 动态导入（处理破折号文件名）
# ─────────────────────────────────────────────

_SKILLS_DIR = os.path.dirname(os.path.abspath(__file__))

def _import_module(module_name: str, filename: str):
    """使用 importlib.util 动态导入带破折号文件名的模块"""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        module_name,
        os.path.join(_SKILLS_DIR, filename)
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

# 导入 SkillDiscoveryEngine 和 SkillInfo
_discovery_module = _import_module("skill_discovery_engine", "skill-discovery-engine.py")
SkillDiscoveryEngine = _discovery_module.SkillDiscoveryEngine
SkillInfo = _discovery_module.SkillInfo

# 导入 SkillMatcher
_matcher_module = _import_module("skill_matcher", "skill-matcher.py")
SkillMatcher = _matcher_module.SkillMatcher

# 导入 SkillMarketClient 和 IntelligentMarketSearch
_market_module = _import_module("skill_market_client", "skill-market-client.py")
SkillMarketClient = _market_module.SkillMarketClient
IntelligentMarketSearch = _market_module.IntelligentMarketSearch
load_client_from_config = _market_module.load_client_from_config


# ─────────────────────────────────────────────
# Checkpoint 4 Enhanced
# ─────────────────────────────────────────────

class Checkpoint4Enhanced:
    """
    检查点4增强版 - 智能Skill发现系统

    将本地skill扫描、智能匹配和市场搜索整合为单一检查点执行流程。
    """

    # 置信度等级阈值（与 skill-config.json 对齐）
    HIGH_CONFIDENCE_THRESHOLD = 0.8
    MEDIUM_CONFIDENCE_THRESHOLD = 0.6
    LOW_CONFIDENCE_THRESHOLD = 0.3

    # 置信度等级标签
    CONFIDENCE_LABELS = {
        'HIGH': '高',
        'MEDIUM': '中',
        'LOW': '低',
        'VERY_LOW': '极低',
    }

    # 置信度对应的 emoji
    CONFIDENCE_EMOJIS = {
        'HIGH': '🎯',
        'MEDIUM': '📋',
        'LOW': '⚠️',
        'VERY_LOW': '❓',
    }

    def __init__(self, config_path: Optional[str] = None):
        """
        初始化检查点4增强版

        Args:
            config_path: skill-config.json 路径，默认使用同目录下的文件
        """
        if config_path is None:
            config_path = os.path.join(_SKILLS_DIR, "skill-config.json")

        self.config_path = config_path

        # 初始化各组件
        self.matcher = SkillMatcher(config_path)
        self.market_client = load_client_from_config(config_path)
        self.market_searcher = IntelligentMarketSearch(self.market_client)

    # ─────────────────────────────────────────────
    # 主执行方法
    # ─────────────────────────────────────────────

    def execute_skill_check(
        self,
        task_description: str,
        agent_type: str = "max",
    ) -> Dict[str, Any]:
        """
        执行完整的检查点4 skill智能发现流程。

        Args:
            task_description: 任务描述（自然语言）
            agent_type:       调用Agent类型（max/ella/jarvis/kyle），用于日志记录

        Returns:
            结构化结果字典:
            {
                "total_skills_scanned":  int,
                "local_matches":         List[Dict],   # [{name, score, confidence_level}]
                "market_results":        List[Dict],   # [{name, score, install_command}]
                "recommended_skills":    List[str],    # 推荐技能名称列表（最多5个）
                "top_match_score":       float,
                "searched_market":       bool,
                "execution_time_ms":     float,
                "confidence_level":      str,          # HIGH / MEDIUM / LOW / VERY_LOW
            }
        """
        start_time = time.monotonic()

        # 1. 本地 skill 扫描 + 智能匹配
        local_matches_raw: List[Tuple[SkillInfo, float]] = self.matcher.match_skills(
            task_description,
            strategy='hybrid',
            max_results=10,
        )

        total_scanned = len(self.matcher.discovery_engine.scan_all_skills())

        # 转换本地匹配结果为可序列化格式
        local_matches: List[Dict[str, Any]] = []
        for skill, score in local_matches_raw:
            confidence_level = self.matcher.get_confidence_level(score)
            local_matches.append({
                'name': skill.name,
                'score': round(score, 4),
                'confidence_level': confidence_level,
                'category': skill.category,
                'description': skill.description[:100] if skill.description else '',
            })

        # 2. 提取技术关键词（用于市场搜索过滤）
        tech_keywords = self._extract_tech_keywords(task_description)
        tech_filters = {'compatibility': tech_keywords[0]} if tech_keywords else {}

        # 3. 智能决策：是否需要市场搜索
        recommend_result = self.market_searcher.recommend(
            local_matches=local_matches_raw,
            task_desc=task_description,
            tech_filters=tech_filters if tech_filters else None,
            time_budget_ms=2000,
        )

        searched_market = recommend_result['decision'] == 'search'

        # 4. 处理市场搜索结果
        market_results: List[Dict[str, Any]] = []
        if searched_market:
            for sr in recommend_result.get('market_results', [])[:5]:
                market_results.append({
                    'name': sr.skill.name,
                    'score': round(sr.relevance_score, 4),
                    'install_command': sr.skill.install_command,
                    'category': sr.skill.category,
                    'rating': sr.skill.rating,
                    'match_reasons': sr.match_reasons,
                })

        # 5. 综合推荐（本地优先，市场补充，最多5个）
        recommended_skills: List[str] = []
        seen: set = set()

        for m in local_matches[:5]:
            name = m['name']
            if name not in seen:
                recommended_skills.append(name)
                seen.add(name)

        for m in market_results:
            if len(recommended_skills) >= 5:
                break
            name = m['name']
            if name not in seen:
                recommended_skills.append(name)
                seen.add(name)

        # 6. 顶级匹配分数 & 整体置信度
        top_match_score: float = local_matches[0]['score'] if local_matches else 0.0
        confidence_level = self._determine_confidence_level(
            top_match_score,
            len(local_matches),
            searched_market,
        )

        execution_time_ms = (time.monotonic() - start_time) * 1000

        return {
            'total_skills_scanned': total_scanned,
            'local_matches': local_matches,
            'market_results': market_results,
            'recommended_skills': recommended_skills,
            'top_match_score': round(top_match_score, 4),
            'searched_market': searched_market,
            'execution_time_ms': round(execution_time_ms, 1),
            'confidence_level': confidence_level,
            'market_decision': recommend_result.get('decision', ''),
            'task_description': task_description,
            'knowledge_context': self.query_knowledge(task_description),
        }

    # ─────────────────────────────────────────────
    # 输出格式化
    # ─────────────────────────────────────────────

    def format_checkpoint_output(self, result: Dict[str, Any]) -> str:
        """
        将 execute_skill_check 结果格式化为检查点4标准输出字符串。

        Args:
            result: execute_skill_check 返回的结果字典

        Returns:
            格式化后的多行字符串，供Max直接输出
        """
        confidence_level = result.get('confidence_level', 'LOW')
        emoji = self.CONFIDENCE_EMOJIS.get(confidence_level, '📋')
        confidence_label = self.CONFIDENCE_LABELS.get(confidence_level, '低')

        total_scanned = result.get('total_skills_scanned', 0)
        recommended = result.get('recommended_skills', [])
        top_score = result.get('top_match_score', 0.0)
        exec_time = result.get('execution_time_ms', 0.0)
        searched_market = result.get('searched_market', False)
        market_results = result.get('market_results', [])

        # 格式化推荐技能列表
        if recommended:
            skills_str = ', '.join(recommended[:5])
        else:
            skills_str = '暂无匹配技能'

        # 匹配度百分比
        match_pct = int(top_score * 100)

        # 市场搜索状态
        market_info = ''
        if searched_market and market_results:
            market_info = f' | 市场: +{len(market_results)}个技能'
        elif searched_market:
            market_info = ' | 市场: 已搜索(无新增)'

        # 构建输出
        lines = [
            f"🧰 检查点4: Skill智能发现 [AI增强] {emoji}",
            f"🔍 扫描结果: 发现 {total_scanned} 个可用skills",
            f"📋 智能推荐: {skills_str}",
            f"💡 匹配度: {match_pct}% | 置信度: {confidence_label} | 响应时间: {exec_time:.0f}ms{market_info}",
        ]

        # 低置信度提示
        if confidence_level in ('LOW', 'VERY_LOW'):
            lines.append("⚠️  提示: 建议详细描述任务或考虑skill市场搜索")

        # 市场搜索信号：供 Claude 检测并调用 findSkill
        market_decision = result.get('market_decision', '')
        if market_decision == 'search':
            query = result.get('task_description', '')
            lines.append(f"MARKET_SEARCH_NEEDED: query={query}")

        # Layer 3 历史经验（FAST/REFERENCE路径时有内容）
        knowledge_context = result.get('knowledge_context', '')
        if knowledge_context:
            lines.append(knowledge_context)

        return '\n'.join(lines)

    def query_knowledge(self, task_description: str) -> str:
        """
        查询Layer 3知识库，返回格式化历史经验字符串。
        查询失败时静默返回空字符串，不影响主流程。
        """
        try:
            import sys
            knowledge_agents = str(Path(__file__).parent.parent / "knowledge" / "agents")
            if knowledge_agents not in sys.path:
                sys.path.insert(0, knowledge_agents)
            from query import KnowledgeQuery
            kq = KnowledgeQuery()
            result = kq.query(task_description)
            return result.formatted_output  # 空字符串 = STANDARD路径
        except Exception:
            return ""  # 知识库不可用时不影响检查点4

    # ─────────────────────────────────────────────
    # 私有辅助方法
    # ─────────────────────────────────────────────

    def _extract_tech_keywords(self, task_description: str) -> List[str]:
        """
        从任务描述中提取技术关键词。

        Args:
            task_description: 任务描述

        Returns:
            技术关键词列表（小写，去重，按频次排序）
        """
        # 已知技术词汇列表（顺序从高权重到低权重）
        tech_vocab = [
            'python', 'javascript', 'typescript', 'java', 'go', 'rust', 'ruby',
            'react', 'vue', 'angular', 'svelte', 'nextjs', 'nuxtjs',
            'django', 'flask', 'fastapi', 'express', 'koa',
            'docker', 'kubernetes', 'k8s', 'aws', 'gcp', 'azure',
            'sql', 'mysql', 'postgresql', 'mongodb', 'redis', 'sqlite',
            'html', 'css', 'sass', 'scss',
            'git', 'github', 'gitlab', 'jenkins', 'circleci',
            'pytest', 'jest', 'mocha', 'playwright', 'selenium',
            'graphql', 'rest', 'grpc', 'openapi', 'swagger',
            'nginx', 'apache', 'caddy',
        ]

        desc_lower = task_description.lower()
        found: List[str] = []
        seen: set = set()

        for tech in tech_vocab:
            # 使用词边界匹配（英文），或直接包含检查（中文混合环境）
            pattern = rf'\b{re.escape(tech)}\b'
            if re.search(pattern, desc_lower) and tech not in seen:
                found.append(tech)
                seen.add(tech)

        return found

    def _determine_confidence_level(
        self,
        top_score: float,
        num_local_matches: int,
        searched_market: bool,
    ) -> str:
        """
        综合多个维度确定整体置信度等级。

        Args:
            top_score:          本地最高匹配分数
            num_local_matches:  本地匹配数量
            searched_market:    是否已触发市场搜索

        Returns:
            'HIGH' | 'MEDIUM' | 'LOW' | 'VERY_LOW'
        """
        # 高置信度：本地顶级分数高，且有多个匹配
        if top_score >= self.HIGH_CONFIDENCE_THRESHOLD and num_local_matches >= 2:
            return 'HIGH'

        # 中置信度：分数中等，或仅有少量匹配
        if top_score >= self.MEDIUM_CONFIDENCE_THRESHOLD:
            return 'MEDIUM'

        # 市场搜索提升置信度：即使本地匹配差，市场补充后可达中等
        if searched_market and top_score >= self.LOW_CONFIDENCE_THRESHOLD:
            return 'MEDIUM'

        # 低置信度：分数低但仍有匹配
        if top_score >= self.LOW_CONFIDENCE_THRESHOLD:
            return 'LOW'

        # 极低：几乎没有匹配
        return 'VERY_LOW'


# ─────────────────────────────────────────────
# 便捷函数
# ─────────────────────────────────────────────

def run_checkpoint4(task_description: str, agent_type: str = "max") -> str:
    """
    一键执行检查点4并返回格式化输出字符串。

    Args:
        task_description: 任务描述
        agent_type:       调用Agent类型

    Returns:
        格式化后的检查点4输出
    """
    cp4 = Checkpoint4Enhanced()
    result = cp4.execute_skill_check(task_description, agent_type)
    return cp4.format_checkpoint_output(result)


# ─────────────────────────────────────────────
# 独立运行（快速测试）
# ─────────────────────────────────────────────

if __name__ == "__main__":
    # 接受命令行参数: python3 checkpoint4_enhanced.py "任务描述" [agent_type]
    if len(sys.argv) >= 2:
        task_description = sys.argv[1]
        agent_type = sys.argv[2] if len(sys.argv) >= 3 else "max"
        cp4 = Checkpoint4Enhanced()
        result = cp4.execute_skill_check(task_description, agent_type)
        print(cp4.format_checkpoint_output(result))
    else:
        # 无参数时运行演示
        print("=" * 60)
        print("  Checkpoint4Enhanced - 快速演示")
        print("=" * 60)

        demo_tasks = [
            "我需要为React前端创建UI组件和设计系统",
            "调试Python服务中的内存泄漏问题",
            "设置Docker + Kubernetes生产部署流程",
        ]

        cp4 = Checkpoint4Enhanced()

        for task in demo_tasks:
            print(f"\n任务: {task}")
            print("-" * 40)
            result = cp4.execute_skill_check(task)
            output = cp4.format_checkpoint_output(result)
            print(output)

        print("\n" + "=" * 60)
        print("  演示完成")
        print("=" * 60)
