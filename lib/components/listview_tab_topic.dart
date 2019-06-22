// 话题列表页

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/common/database_helper.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/model/web/item_tab_topic.dart';
import 'package:flutter_app/network/dio_web.dart';
import 'package:flutter_app/pages/page_topic_detail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class TopicListView extends StatefulWidget {
  final String tabKey;

  TopicListView(this.tabKey);

  @override
  State<StatefulWidget> createState() => new TopicListViewState();
}

class TopicListViewState extends State<TopicListView> with AutomaticKeepAliveClientMixin {
  Future<List<TabTopicItem>> topicListFuture;

  @override
  void initState() {
    super.initState();
    // 获取数据
    topicListFuture = getTopics();
  }

  Future<List<TabTopicItem>> getTopics() async {
    return await DioWeb.getTopicsByTabKey(widget.tabKey, 0);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<TabTopicItem>>(
        future: topicListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new RefreshIndicator(
                child: new Container(
                    child: ListView.builder(
                        itemBuilder: (context, index) => TopicItemView(snapshot.data[index]),
                        itemCount: snapshot.data.length)),
                onRefresh: _onRefresh);
          } else if (snapshot.hasError) {
            print("wmllll:${snapshot.error}");
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(S.of(context).oops),
                RaisedButton.icon(
                  onPressed: () {
                    _onRefresh();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text(S.of(context).retry),
                )
              ],
            );
          }
          // By default, show a loading skeleton
          return LoadingList();
        });
  }

  //刷新数据,重新设置future就行了
  Future _onRefresh() async {
    setState(() {
      topicListFuture = getTopics();
    });
  }

  @override
  bool get wantKeepAlive => true;
}

/// topic item view
class TopicItemView extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;
  final TabTopicItem topic;

  TopicItemView(this.topic);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 保存到数据库（新增或者修改之前记录到最前面）
        // 添加到「近期已读」
        dbHelper.insert(topic);

        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => new TopicDetails(topic.topicId)),
        );
      },
      child: new Container(
        padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              topic.topicContent,
              // 区分：已读 or 未读 todo
              style: new TextStyle(fontSize: 17),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                // 头像
                ClipOval(
                  child: new CachedNetworkImage(
                    imageUrl: "https:" + topic.avatar,
                    height: 21.0,
                    width: 21.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(Icons.account_circle, size: 21.0, color: Color(0xFFcccccc)),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  topic.memberId,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  style: new TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Theme.of(context).disabledColor),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  padding: EdgeInsets.only(top: 1, bottom: 1, left: 4, right: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: new Text(
                    topic.nodeName,
                    style: new TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Offstage(
                  offstage: topic.lastReplyTime == '',
                  child: Text(
                    topic.lastReplyTime,
                    style: new TextStyle(color: Theme.of(context).disabledColor, fontSize: 12.0),
                  ),
                ),
                Spacer(),
                Offstage(
                  offstage: topic.replyCount == '',
                  child: Row(
                    children: <Widget>[
                      new Icon(
                        FontAwesomeIcons.comment,
                        size: 14.0,
                        color: Colors.grey,
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: new Text(
                          topic.replyCount,
                          style: new TextStyle(fontSize: 13.0, color: Theme.of(context).unselectedWidgetColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Column(
              children: [0, 1, 2, 3, 4, 5, 6]
                  .map((_) => Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 15.0,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: <Widget>[
                                ClipOval(
                                  child: Container(
                                    width: 21.0,
                                    height: 21.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  width: 40.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  width: 40.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  width: 40.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                                Spacer(),
                                Icon(
                                  FontAwesomeIcons.comment,
                                  size: 16.0,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Container(
                                  width: 20.0,
                                  height: 10.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )),
    );
  }
}
