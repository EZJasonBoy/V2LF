// node listview
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/models/web/item_node_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:flutter_app/theme/theme_data.dart';

class NodeTopicListView extends StatefulWidget {
  final String tabKey;

  NodeTopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<NodeTopicListView> with AutomaticKeepAliveClientMixin {
  int p = 1;
  bool isUpLoading = false;
  List<NodeTopicItem> items = new List();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    // 获取数据
    getTopics();
    // 监听是否滑到了页面底部
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("加载更多...");
        getTopics();
      }
    });
  }

  Future getTopics() async {
    if (!isUpLoading) {
      isUpLoading = true;
      List<NodeTopicItem> newEntries = await DioWeb.getNodeTopicsByTabKey(widget.tabKey, p++);
      // 用来判断节点是否需要登录后查看
      if (newEntries.isEmpty) {
        Navigator.pop(context);
        return;
      }

      print(p);
      setState(() {
        items.addAll(newEntries);
        isUpLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (items.length > 0) {
      return new RefreshIndicator(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  // 滑到了最后一个item
                  return _buildLoadText();
                } else {
                  return new TopicItemView(items[index]);
                }
              }),
          onRefresh: _onRefresh);
    }
    // By default, show a loading spinner
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _buildLoadText() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Text(S.of(context).loadingPage(p.toString())),
      ),
    );
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    print("刷新数据...");
    p = 1;
    List<NodeTopicItem> newEntries = await DioWeb.getNodeTopicsByTabKey(widget.tabKey, p);
    setState(() {
      items.clear();
      items.addAll(newEntries);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

/// topic item view
class TopicItemView extends StatelessWidget {
  final NodeTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic.topicId)),
        );
      },
      child: new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: new Row(
                children: <Widget>[
                  /*// 头像
                  new Container(
                    margin: const EdgeInsets.only(right: 10.0),
                    width: 24.0,
                    height: 24.0,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(topic.avatar),
                      ),
                    ),
                  ),*/
                  new Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// title
                            new Container(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                topic.title,
                                style: Theme.of(context).textTheme.subhead,
                              ),
                            ),
                            new Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              child: new Row(
                                children: <Widget>[
                                  new Text(topic.memberId,
                                      textAlign: TextAlign.left, maxLines: 1, style: Theme.of(context).textTheme.caption),
                                  new Text(' • ${topic.characters} • ${topic.clickTimes}',
                                      textAlign: TextAlign.left, maxLines: 1, style: Theme.of(context).textTheme.caption),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  Offstage(
                    offstage: topic.replyCount == '0',
                    child: Material(
                      color: MyTheme.appMainColor[400],
                      shape: new StadiumBorder(),
                      child: new Container(
                        width: 35.0,
                        height: 20.0,
                        alignment: Alignment.center,
                        child: new Text(
                          topic.replyCount,
                          style: new TextStyle(fontSize: 12.0, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            new Divider(
              height: 6.0,
            )
          ],
        ),
      ),
    );
  }
}
